import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/Enumerates/LayerType.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerSetting.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerVarious.dart';


class SnowAnimation extends StatefulWidget implements CustomizableWidget{
  final double snowNumber; // 個数
  final double speed; // 落下速度
  final Size screenSize; // screenSize
  final bool isGradient;
  final Color color;

  SnowAnimation({
    this.snowNumber = 50.0,
    this.speed = 0.1,
    this.screenSize,
    this.isGradient = false,
    this.color = Colors.white,
  }): assert(screenSize != null);

  @override
  _SnowAnimationState createState() => _SnowAnimationState();

  // CustomizableWidget
  @override
  LayerType layerType = LayerType.snowAnimation;
  @override
  Map<String, dynamic> setting;

  static List<LayerProp> getSettingList(){
    List<LayerProp> list = [
      LayerProp(layerPropType: LayerPropType.number,  entry: 'snowNumber', description: '雪の数を指定できます', initValue: 50.0),
      LayerProp(layerPropType: LayerPropType.number,  entry: 'speed', description: null, initValue: 0.2),
      LayerProp(layerPropType: LayerPropType.boolean, entry: 'isGradient',   description: '角度を付けます', initValue: true),
      LayerProp(layerPropType: LayerPropType.color,   entry: 'color',  description: '色を指定できます', initValue: ColorType.red),
    ];
    return list;
  }

  factory SnowAnimation.fromLayerPropList(List<LayerProp> list, Size screenSize){
    return SnowAnimation(
      snowNumber: list[0].result,
      speed: list[1].result,
      screenSize: screenSize,
      isGradient: list[2].result,
      color: ColorProp.getColor(list[3].result),
    );
  }

  @override
  String imagePath = 'images/dopper.jpg';

  @override
  String widgetNameJP = '雪';
}

class _SnowAnimationState extends State<SnowAnimation> with SingleTickerProviderStateMixin{

  AnimationController controller;
  Animation animation;

  List<Snow> snows;

  Size screenSize;

  @override
  void initState(){
    super.initState();

    screenSize = widget.screenSize;
    _createSnows();

    controller = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed){
        controller.reset();
      } else if (status == AnimationStatus.dismissed){
        controller.forward();
      }
    });

    controller.addListener((){
      setState(() {
        _update();
      });
    });
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  // sizeと比例した落下速度
  void _createSnows(){
    snows = List();
    final _rnd = Random();
    for (int i = 0; i < widget.snowNumber; i++){
      var _snowSize = _rnd.nextDouble() + 0.01;
      if (widget.isGradient) {
        snows.add(
          Snow(
            dx: _rnd.nextDouble() * 2 - 1,
            dy: _rnd.nextDouble() * 2 - 1,
            radius: _snowSize / 100,// * 8,
            speed: (_snowSize + 0.01) / screenSize.height,
            alpha: _rnd.nextDouble() / 2 + 0.5,//下駄はかせて0.5<a<1.0へ
            color: widget.color,
          )
        );
      } else {
        snows.add(
          Snow(
            dx: _rnd.nextDouble() * screenSize.width,
            dy: _rnd.nextDouble() * screenSize.height,
            radius: _snowSize * 3,
            speed: _snowSize,
            alpha: _rnd.nextDouble() / 2 + 0.5,//下駄はかせて0.5<a<1.0へ
            color: widget.color,
          )
        );
      }
    }
  }

  void _update(){
    for (int i = 0; i < widget.snowNumber; i++){
      snows[i].dy += snows[i].speed;
      if (snows[i].dy > screenSize.height) {
        snows[i].dy = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var _painter;
    if (widget.isGradient){
      _painter = GradientSnowPainter(snows: snows);
    } else {
      _painter = SnowPainter(snows: snows);
    }

    return Center(
      child: CustomPaint(
        painter: _painter,
        child: Container(
          height: screenSize.height,
        ),
      ),
    );
  }
}


//拡張性を持たせる気がないのでここでは位置と速度と透明度だけ．角度も変える？
class Snow{
  double dx, dy;
  double radius;
  double speed;
  double alpha;
  Color color;

  Snow({
    this.dx,
    this.dy,
    this.radius,
    this.speed,
    this.alpha,
    this.color,
  });
}

//円形の描画
// やるべきなのは、円のサイズに応じて描画する円の個数を変えること。
// 0.5,1 とするなら、中心円は最低」0.5で、そこから指数関数的に遠ざかっていくのでいいと思う。
class SnowPainter extends CustomPainter{
  List<Snow> snows;
  SnowPainter({
    this.snows,
  });

  @override
  void paint(Canvas canvas, Size size){
    final Paint paintBase = new Paint()
      ..color       = snows[0].color.withOpacity(0.5)
      ..isAntiAlias = true;

    final Paint paintCenter = new Paint()
      ..color       = snows[0].color.withOpacity(0.8)
      ..isAntiAlias = true;

    for (Snow snow in snows) {
      canvas.drawCircle(Offset(snow.dx, snow.dy), snow.radius,     paintBase);
      canvas.drawCircle(Offset(snow.dx, snow.dy), snow.radius / 2, paintCenter);
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) => true;
}


//10フレームでない but high quality
class GradientSnowPainter extends CustomPainter{
  List<Snow> snows;
  GradientSnowPainter({
    this.snows,
  });

  @override
  void paint(Canvas canvas, Size size){
    var rect = Offset.zero & size;
    for (Snow snow in snows) {
      var gradient = RadialGradient(
          center: Alignment(snow.dx, snow.dy),//位置
          radius: snow.radius,//半径
          colors: [snow.color, snow.color.withOpacity(0.0)],//色の変遷 中心部->端(というか端よりも外の背景)
          stops: [0.3, 1.0]//塗りつぶし、グラデーション、塗りつぶしの区切り点
      );
      canvas.drawRect(
        rect,
        Paint()..shader = gradient.createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(GradientSnowPainter oldDelegate) => true;
}