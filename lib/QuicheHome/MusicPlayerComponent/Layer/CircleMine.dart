import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/Enumerates/LayerType.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerSetting.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerVarious.dart';

//余りにも重いなら、ここで複数を処理できるようにしないといけない

class CircleMine extends StatefulWidget implements CustomizableWidget{
  final int sweepWidth, startWidth;
  final double initialSweepPosition, initialStartWidth;
  final Size screenSize;

  final double diameter, longSide, shortSide;
  final double strokeWidth;

  final Color color;

  CircleMine({
    this.startWidth = 4,
    this.sweepWidth = 8,
    this.initialStartWidth = 0.0,
    this.initialSweepPosition = 0.0,
    @required this.screenSize,
    this.diameter,
    this.longSide,
    this.shortSide,
    this.strokeWidth = 1,
    this.color = Colors.white,
  }) : assert(diameter != null || (longSide != null && shortSide != null));

  @override
  _CircleState createState() => _CircleState();

  // implements 用
  @override
  LayerType layerType = LayerType.circleMine;

  @override
  Map<String, dynamic> setting;

  static List<LayerProp> getSettingList(){
    List<LayerProp> list = [
      LayerProp(layerPropType: LayerPropType.number,  entry: 'startWidth', description: '0~360度を指定できます', initValue: 4),
      LayerProp(layerPropType: LayerPropType.number,  entry: 'sweepWidth', description: '0~360度を指定できます', initValue: 8),
      LayerProp(layerPropType: LayerPropType.number,  entry: 'initialStartWidth', description: '初期の角度を指定できます', initValue: 0.0),
      LayerProp(layerPropType: LayerPropType.number,  entry: 'initialSweepPosition', description: '初期の幅を指定できます', initValue: 0.0),
      LayerProp(layerPropType: LayerPropType.number,  entry: 'diameter', description: 'もし長辺、短辺で指定するときは0を入力してください', initValue: 300),
      LayerProp(layerPropType: LayerPropType.number,  entry: 'longSide', description: '長辺', initValue: 300),
      LayerProp(layerPropType: LayerPropType.number,  entry: 'shortSide', description: '短辺', initValue: 300),
      LayerProp(layerPropType: LayerPropType.number,  entry: 'strokeWidth', description: '線の幅', initValue: 1),
      LayerProp(layerPropType: LayerPropType.color,   entry: 'color',  description: '色', initValue: ColorType.red),
    ];
    return list;
  }

  factory CircleMine.fromLayerPropList(List<LayerProp> list, Size screenSize){
    var diameter_tmp = list[4].result;
    var longSide_tmp = list[5].result.toDouble();
    var shortSide_tmp = list[6].result.toDouble();
    if (diameter_tmp != 0){
      longSide_tmp = null; shortSide_tmp = null;
    }

    return CircleMine(
      screenSize: screenSize,
      startWidth: list[0].result,
      sweepWidth: list[1].result,
      initialStartWidth: list[2].result,
      initialSweepPosition: list[3].result,
      diameter: diameter_tmp.toDouble(),
      longSide: longSide_tmp,
      shortSide: shortSide_tmp,
      strokeWidth: list[7].result.toDouble(),
      color: ColorProp.getColor(list[8].result),
    );
  }

  static String imagePath = 'images/dopper.jpg';
}

class _CircleState extends State<CircleMine> with SingleTickerProviderStateMixin {

  AnimationController controller;
  CircleProperty cp;
  double longSide, shortSide;

  @override
  void initState() {
    super.initState();

    if (widget.longSide != null && widget.shortSide != null){
      longSide = widget.longSide; shortSide = widget.shortSide;
    }else if (widget.diameter != null){
      longSide = widget.diameter; shortSide = widget.diameter;
    }

    createDefaultData();

    controller = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.addListener(() {
      setState(() {
        _update();
      });
    });
  }

  void createDefaultData(){
    cp = CircleProperty(
      startAngle: widget.initialStartWidth,
      sweepAngle: widget.initialSweepPosition,
      shortSide: shortSide,
      longSide: longSide,
      strokeWidth: widget.strokeWidth,
      color: widget.color,
    );
  }

  bool updateTime = true; //true:circle open, false:circle close
  void _update() {
    if (updateTime){
      cp.sweepAngle = (cp.sweepAngle + widget.sweepWidth);
      if (cp.sweepAngle >= 360){
        cp.sweepAngle = 360;
        updateTime = !updateTime;
      }
    }else{
      cp.sweepAngle = (cp.sweepAngle - widget.sweepWidth);
      cp.startAngle = (cp.startAngle + widget.sweepWidth) % 360;//デザイン上必要
      if (cp.sweepAngle <= 0){
        cp.sweepAngle = 0;
        updateTime = !updateTime;
      }
    }

    setState(() {
      cp.startAngle = (cp.startAngle + widget.startWidth) % 360;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: CustomPaint(
        painter: CirclePainter(cp),
        child: Container(
          color: Colors.white.withOpacity(0.0),
          width: widget.screenSize.width,
          height: widget.screenSize.height,
        ),
      ),
    );
  }
}

class CircleProperty {
  double startAngle;
  double sweepAngle;
  double shortSide, longSide;
  double strokeWidth;

  Color color;

  CircleProperty({
    this.startAngle,
    this.sweepAngle,
    this.shortSide,
    this.longSide,
    this.strokeWidth,
    this.color,
  });
}

class CirclePainter extends CustomPainter {
  CircleProperty cp;
  CirclePainter(this.cp);

  @override
  void paint(Canvas canvas, Size size) {
    Paint brush = new Paint()
      ..color = cp.color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = cp.strokeWidth;

    double left, top, right, bottom;
    left= (size.width / 2) - (cp.shortSide / 2);
    top= (size.height / 2) - (cp.longSide / 2);
    right= (size.width / 2) + (cp.shortSide / 2);
    bottom= (size.height / 2) + (cp.longSide / 2);


    canvas.drawArc(Rect.fromLTRB(left, top, right, bottom),
        (cp.startAngle*3.14)/180,
        (cp.sweepAngle*3.14)/180,
        false, brush);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

































