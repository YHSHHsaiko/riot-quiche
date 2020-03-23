import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheHome/MusicList.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/BackGround.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';
import 'package:riot_quiche/QuicheHome/Widgets/AutoScrollText.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';


//
//曲が一曲もない時のデフォルトを用意していないのでそこでばぐる,もしない時はリストの画面でも呼ぶ？

class MusicPlayer extends StatefulWidget{
  MusicPlayer(this.tagJucket, this._music);
  String tagJucket;
  Music _music;

  @override
  State<StatefulWidget> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> with SingleTickerProviderStateMixin{
  AnimationController _controller;
  Animation<Offset> _offsetFooter, _offsetHeader, _offsetAnimation;
  var foldControllBar = true;

  double heightRateHeader, heightRateFooter;

  @override
  void initState() {
    super.initState();
    //TODO : ない時が回避されていない
    if (widget._music == null ){
      print('what null;');
      widget._music = QuicheOracleVariables.musicList[0];
    }

    print(widget.tagJucket);
    print(widget._music.title);

    PlatformMethodInvoker.setCurrentMediaId(widget._music.id);
    PlatformMethodInvoker.playFromCurrentMediaId();
    print('initState');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetFooter = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _offsetHeader = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    heightRateHeader = 0.1;
    heightRateFooter  = 0.3;

    var pos = 0.5 - (1 - heightRateFooter - heightRateHeader);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, pos),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///スクリーンサイズを高くすることで縦方向の余計な描画も行えるので、そこで調整？
    Size size = MediaQuery.of(context).size;
    final jacketSize = (size.width < size.height ? size.width : size.height) * 0.6;
    Size longSize = Size(size.width, size.height * 1.2);

    var imagePath = "images/dopper.jpg";

    return Scaffold(
      body: SafeArea(
        top: true,
        child: Stack(
          children: <Widget>[
            // BACK_GROUND
            BackGround(imagePath),
            // Stacks Layer
            SlideTransition(
              position: _offsetAnimation,
              child: Stack(
                children: <Widget>[

                  // LAYERS
                  SnowAnimation(
                    snowNumber: 50,
                    screenSize: longSize,
                    isGradient: false,
                  ),


                  // Gesture Layer
                  Center(
                    child: GestureDetector(
                      onTap: (){
                        if (foldControllBar){
                          _controller.forward();
                        }else {
                          _controller.reverse();
                        }
                        setState(() {
                          foldControllBar = !foldControllBar;
                        });
                      },
                      onPanUpdate: (pos) {
                        setState(() {
                          widget.tagJucket = "playnow";
                        });
                        Navigator.push(
                          context,
                          new MaterialPageRoute<Null>(
                            settings: const RouteSettings(name: "/musicList"),
                            builder: (BuildContext context) => MusicList(),
                          ),
                        );
                      },
                      child: Container(
                        height: size.height,
                        width: size.width,
                        color: Colors.blue.withOpacity(0.0),
                      ),
                    ),
                  ),


                  // Jacket Image
                  Center(
                    child: GestureDetector(
                      onTap: (){
                        print("Tap Jucket Image!");
                      },
                      child: Hero(
                        tag: widget.tagJucket, // playnow or newplay
                        child: Container(
                          width: jacketSize,
                          height: jacketSize,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage(imagePath),
                              )
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            //Controllers
            // Header
            Align(
              alignment: Alignment.topCenter,
              child: SlideTransition(
                position: _offsetHeader,
                child: Container(
                  color: Colors.blueGrey.withOpacity(0.0),
                  height: size.height * heightRateHeader,
                  child: MusicPlayerHeader(widget._music.title),
                ),
              ),
            ),

            // Footer
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _offsetFooter,
                child: Container(
                  color: Colors.blueGrey.withOpacity(0.0),
                  height: size.height * heightRateFooter,
                  child: MusicPlayerFooter(widget._music),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


















//コンストラクタ作って、値渡すだけでできるように。
//特にタイトル等

//縦のサイズから文字サイズというか縦のサイズを決め打つ。

class MusicPlayerHeader extends StatelessWidget{
  String str = '';

  MusicPlayerHeader(this.str);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double h = size.height*0.1;
    return Row(
      children: <Widget>[
        SizedBox(
          width: h,
          child: Icon(Icons.more_vert),
        ),
        SizedBox(
          height: h,
          width: size.width - 2*h,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: h,
                child: AutoScrollText(
                  text: str,
                  textStyle: TextStyle(fontSize: h/2.5),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: h,
          child: Icon(Icons.search),
        ),
      ],
    );
  }
}




















enum ButtonMenuEnum{
  shuffle,
  prev,
  play,
  next,
  repeat,
}

enum ButtonIconEnum{
  icon,
  animatedIcon,
  image, // Require "Image" class.
}

class ButtonProperty{
  ButtonMenuEnum bme;
  ButtonIconEnum bie;
  double circleSize;
  dynamic icon;

  ButtonProperty({
    @required this.bme,
    @required this.bie,
    @required this.circleSize,
    @required this.icon,
  });
}




class MusicPlayerFooter extends StatefulWidget{
  Music _music;
  MusicPlayerFooter(this._music);
  @override
  State<StatefulWidget> createState() => MusicPlayerFooterState();
}

class MusicPlayerFooterState extends State<MusicPlayerFooter> with SingleTickerProviderStateMixin{
  List<ButtonProperty> listButtons;
  double sliderValue = 0;
  AnimationController _animatedIconController;
  bool _animatedIconControllerChecker = true;

  @override
  void initState() {
    _animatedIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    listButtons = [
      ButtonProperty(bme:ButtonMenuEnum.shuffle, bie: ButtonIconEnum.icon, circleSize:15, icon: Icons.shuffle),
      ButtonProperty(bme:ButtonMenuEnum.prev,    bie: ButtonIconEnum.icon, circleSize:25, icon: Icons.skip_previous),
      ButtonProperty(bme:ButtonMenuEnum.play,    bie: ButtonIconEnum.animatedIcon, circleSize:40, icon: AnimatedIcons.pause_play),
      ButtonProperty(bme:ButtonMenuEnum.next,    bie: ButtonIconEnum.image, circleSize:25, icon: Image.asset("images/dopper.jpg"),),//Icons.skip_next//Image.asset("images/dopper.jpg"))
      ButtonProperty(bme:ButtonMenuEnum.repeat,  bie: ButtonIconEnum.icon, circleSize:15, icon: Icons.repeat),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        Expanded(
          flex: 5,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _Buttons(),
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8,0,8,0),
                    child: Center(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.grey,
                          inactiveTrackColor: Colors.white,
                          trackHeight: 1.0,
                          thumbColor: Colors.blueGrey,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayColor: Colors.grey.withAlpha(32),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 8.0),
                        ),
                        child: Slider(
                          onChanged: (double value) {
                            setState(() {
                              sliderValue = value;
                            });

                            //TODO ここでjava側に再生場所を送る。
                          },
                          value: sliderValue,
                          max: 12312,
                          min: 0,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16,0,16,0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("現在の再生時間を取得"),
                        Text(millSec2SecStr(widget._music.duration)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _Buttons() {
    List<Widget> list = [];
    for (var l in listButtons){
      // set button widget.
      Widget wid;
      switch (l.bie){
        case ButtonIconEnum.icon:
          wid = Icon(
            l.icon,
            color: Colors.white,
            size: l.circleSize,
          );
          break;
        case ButtonIconEnum.animatedIcon:
          wid = AnimatedIcon(
            icon: l.icon,
            progress: _animatedIconController,
            size: l.circleSize,
          );
          break;
        case ButtonIconEnum.image:
          wid = Container(
            width: l.circleSize,
            height: l.circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: l.icon.image,
              ),
            ),
          );
          break;
      }
      // set function in onpressed
      Function func; // onpressed function;
      switch (l.bme){
        case ButtonMenuEnum.shuffle:
          func = () => print("Call shuffle event.");
          break;
        case ButtonMenuEnum.prev:
          func = () => print("Call prev event.");
          break;
        case ButtonMenuEnum.next:
          func = () => print("Call next event.");
          break;
        case ButtonMenuEnum.repeat:
          func = () => print("Call repeat event.");
          break;
        case ButtonMenuEnum.play:
          func = (){
            if (_animatedIconControllerChecker){
              _animatedIconController.forward();
              PlatformMethodInvoker.pause();
            }else{
              _animatedIconController.reverse();
              PlatformMethodInvoker.playFromCurrentMediaId();
            }
            _animatedIconControllerChecker = !_animatedIconControllerChecker;



            print(QuicheOracleVariables.musicList.length);
          };
          break;
      }
      list.add(
        Expanded(
          flex: 1,
          child: RawMaterialButton(
            onPressed: func,
            child: wid,
            shape: new CircleBorder(),
            highlightColor: Colors.white.withOpacity(0.0),
            padding: const EdgeInsets.all(10.0),
          ),
        ),
      );
    }
    return list;
  }



  @override
  void dispose() {
    _animatedIconController.dispose();
    super.dispose();
  }
}









///ミリ秒を秒に直す。return 00:00
String millSec2SecStr(int mills){
  int sec = (mills / 1000).floor();
  String res = '';

  List<int> list = [60,60,24,0];
  for (int i = 0; i < list.length - 1; i++){
    int amari = sec % list[i];
    sec = (sec / list[i]).floor();
    list[i] = amari;
    if (list[i+1] == 0){
      list[i+1] = sec;
    }
  }
  for (int i = list.length - 1; i >= 0; i--){
    if (list[i] != 0){
      res = res + list[i].toString().padLeft(2, "0");
      if (i != 0){
        res = res + ':';
      }
    }
  }
  return res;
}




