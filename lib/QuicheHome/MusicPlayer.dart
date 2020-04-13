import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/ExoPlayerPlaybackState.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicLayerSetting.dart';
import 'package:riot_quiche/QuicheHome/MusicList.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/BackGround.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/Circle.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';
import 'package:riot_quiche/QuicheHome/Widgets/AutoScrollText.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';



class MusicPlayer extends StatefulWidget{
  final scSize;
  MusicPlayer(this.scSize);

  @override
  State<StatefulWidget> createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> with SingleTickerProviderStateMixin{
  /// MusicPlayer Hard Cording
  double heightRateHeader = 0.1, heightRateFooter = 0.3;
  final imagePath = "images/dopper.jpg";

  /// MusicPlayer variables
  // controlls Animation
  AnimationController _controller;
  Animation<Offset> _offsetFooter, _offsetHeader, _offsetAnimation;
  var foldControllBar = false;

  // controlls Music
  Music _music;
  static int nowPlayIndexOfQueue = 1;
  List<dynamic> musicList, moveIndexList;
  static bool shuffleChecker = false;
  static int repeatChecker = 0;

  // controlls Layers
  List<Widget> layers = [];
  List<Widget> mustLayers = [];


  @override
  void initState() {
    super.initState();
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

    double pos = 0.5 - (1 - heightRateFooter - heightRateHeader);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, pos),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // TODO ここでPreference使って、曲データを参照する。
    // Set Initial Music.
    callbackSetMusic([QuicheOracleVariables.musicList[0]], 0);

    // Index List For Shuffle.
    moveIndexList = List<dynamic>.generate(musicList.length, (i) => (i+1) % musicList.length);

    //TODO: foldControllBar を読み込む
    if (foldControllBar){
      _controller.reverse();
      print('reverse');
    }else {
      _controller.forward();
      print('forword');
    }


    // TODO :　仮で作っている表示用データ。この辺どうにかしないと
    double jacketSize = (widget.scSize.width < widget.scSize.height ? widget.scSize.width : widget.scSize.height) * 0.6;
    layers.addAll([
      SnowAnimation(
        snowNumber: 50,
        screenSize: widget.scSize,
        isGradient: false,
      ),

      CircleMine(
        screenSize: widget.scSize,
        diameter: jacketSize+50,
        color: Colors.amber,
      ),

      CircleMine(
        screenSize: widget.scSize,
        diameter: jacketSize+70,
        strokeWidth: 2,
        color: Colors.redAccent,
      ),

      CircleMine(
        screenSize: widget.scSize,
        diameter: jacketSize+90,
        color: Colors.blue,
        strokeWidth: 2,
//        startWidth: 90,
      ),]
    );

//    layers.clear();


  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }



  /// Callback Function for Footer.
  // if pattern == shuffle => flag is bool
  // if pattern == nextAndPrev => flag is String
  void forFooterCallBack(String pattern, var flag){
    switch (pattern){
      case 'shuffle':
        var listIndex;
        if (shuffleChecker){
          listIndex = shuffleItems(List<dynamic>.generate(musicList.length, (i) => i));
        }else{
          listIndex = List<dynamic>.generate(musicList.length, (i) => (i+1) % musicList.length);
        }
        setState(() {
          moveIndexList = listIndex;
        });
        break;
      case 'nextAndPrev':
        int len = musicList.length;
        print(moveIndexList);
        if (flag == 'next'){
          nowPlayIndexOfQueue = moveIndexList[nowPlayIndexOfQueue];
        }else if (flag == 'prev'){
          int prevNumber;
          for (int idx = 0; idx < moveIndexList.length; idx++){
            if(moveIndexList[idx] == nowPlayIndexOfQueue){
              prevNumber = idx;
            }
          }
          nowPlayIndexOfQueue = prevNumber;
        }else if (flag == 'unChange'){
          //何もしない
        }
        setState(() {
          _music = musicList[nowPlayIndexOfQueue];
          PlatformMethodInvoker.setCurrentQueueIndex(nowPlayIndexOfQueue);
          PlatformMethodInvoker.playFromCurrentQueueIndex();
          MusicPlayerFooterState.animatedIconControllerChecker = true;
        });
        break;
    }
  }


  /// Callback Function for SetMusic.
  void callbackSetMusic(var music, int playIndex){
    if (music is Music){
      setState(() {
        _music = music;
        PlatformMethodInvoker.setCurrentMediaId(_music.id);
        PlatformMethodInvoker.playFromCurrentMediaId();
      });
    }else{
      List<String> idList = [];
      for (var m in music){
        idList.add(m.id);
      }
      setState(() {
        _music = music[playIndex];
        musicList = music;
        nowPlayIndexOfQueue = playIndex;
        forFooterCallBack('shuffle', null);
        PlatformMethodInvoker.setQueue(idList);
        PlatformMethodInvoker.setCurrentQueueIndex(nowPlayIndexOfQueue);
        PlatformMethodInvoker.playFromCurrentQueueIndex();
      });
    }
    setState(() {
      MusicPlayerFooterState.animatedIconControllerChecker = true;
    });
  }

  /// callback for layer
  void callbackSetLayer(List<Widget> list){
    setState(() {
      print('set');
      layers = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double jacketSize = (size.width < size.height ? size.width : size.height) * 0.6;
    final Size longSize = Size(size.width, size.height * 1.2);

    Image returnsImageArt = _music.getArt();
    ImageProvider jacketImage = returnsImageArt == null ? AssetImage(imagePath) : returnsImageArt.image;

    mustLayers.addAll([
      // Gesture Layer
      Center(
        child: GestureDetector(
          onTap: (){
            foldControllBar ? _controller.forward(): _controller.reverse();
            setState(() {
              foldControllBar = !foldControllBar;
            });
          },
          onPanUpdate: (pos){
            showDialog(
              context: context,
              builder: (_) {
                return MusicList(this.callbackSetMusic, _music);
              },
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
          child: Container(
            width: jacketSize,
            height: jacketSize,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: jacketImage,
                )
            ),
          ),
        ),
      ),
    ]);




//    layers.addAll(mustLayers);

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          top: true,
          child: Stack(
            children: <Widget>[
              // BACK_GROUND
              BackGround(jacketImage),

              // Stacks Layer
              SlideTransition(
                position: _offsetAnimation,
                child: Stack(
                  children: layers + mustLayers,
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
                    child: MusicPlayerHeader(_music.title, this.callbackSetLayer, layers),
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
                    child: MusicPlayerFooter(_music, forFooterCallBack),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}



















//縦のサイズから文字サイズというか縦のサイズを決め打つ。

class MusicPlayerHeader extends StatelessWidget{
  String str = '';

  Function callbackForLayer;
  List<Widget> layerList;

  MusicPlayerHeader(this.str, this.callbackForLayer, this.layerList);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double fieldHeight = size.height*0.1;
    return Row(
      children: <Widget>[
        // Leading Icon
        SizedBox(
          width: fieldHeight,
          child: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              print('more_vert');
            },
          ),
        ),

        // AutoScrollText
        SizedBox(
          height: fieldHeight,
          width: size.width - 2*fieldHeight,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: fieldHeight,
                child: AutoScrollText(
                  text: str,
                  textStyle: TextStyle(fontSize: fieldHeight / 2.5),
                ),
              ),
            ],
          ),
        ),

        // Trailing Icon
        SizedBox(
          width: fieldHeight,
          child: IconButton(
            icon: Icon(Icons.layers),
            onPressed: () {
              print('layers');
              showDialog(
                context: context,
                builder: (_) {
                  return MusicLayerSetting(callbackForLayer, layerList);
                },
              );
            },
          ),
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

class MusicPlayerFooter extends StatefulWidget{
  final Music _music;
  final Function _callback;
  MusicPlayerFooter(this._music, this._callback);

  @override
  State<StatefulWidget> createState() => MusicPlayerFooterState();
}

class MusicPlayerFooterState extends State<MusicPlayerFooter> with SingleTickerProviderStateMixin{
  /// MusicPlayerFooter Variables
  AnimationController _animatedIconController;
  static bool animatedIconControllerChecker = true; //再生時：true, 停止時：false.
  Size screenSize;

  /// Controlls Buttons & Slider
  double sliderValue = 0;
  int nowSliderPosition = 0;

  @override
  void initState() {
    _animatedIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    PlatformMethodInvoker.redShift(this.forOnData);

    super.initState();
  }

  void forOnData(position, state){
    setState(() {
      sliderValue = position.toDouble();
      if (position.toDouble() > widget._music.duration.toDouble()){
        sliderValue = 0; position = 0;
        if (MusicPlayerState.repeatChecker == 0){ //その場で停止
          //何もしないで初期化
        }else if (MusicPlayerState.repeatChecker == 1){ //ただ最初に戻る
          widget._callback('nextAndPrev', 'next');
        }else if (MusicPlayerState.repeatChecker == 2){ //曲を次のものにして最初に戻る。
          widget._callback('nextAndPrev', 'unchanged');
        }
      }
      nowSliderPosition = position;
    });
    print(state);
    bool _flagsForAnimatedIconControllerChecker = animatedIconControllerChecker;
    if (state == 1 || state == 2){ //stop:1, pause:2, play:3.
      _animatedIconController.forward();
      _flagsForAnimatedIconControllerChecker = false;
    }else if (state == 3){
      _animatedIconController.reverse();
      _flagsForAnimatedIconControllerChecker = true;
    }
    setState(() {
      animatedIconControllerChecker = _flagsForAnimatedIconControllerChecker;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buttons(),
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: Container(
            child: Center(
              child: _slider(),
            ),
          ),
        ),
      ],
    );
  }

  /// Buttons Settings
  List<Widget> _buttons() {
    double iconSize = screenSize.width / 10;
    List<Widget> list = [];
    for (var value in ButtonMenuEnum.values){
      Widget wid;
      Function func;
      switch (value){
        case ButtonMenuEnum.shuffle:
          wid = Icon(
            Icons.shuffle,
            size: iconSize * 0.75,
            color: MusicPlayerState.shuffleChecker ? Colors.black : Colors.grey,
          );
          func = (){
            setState(() {
              MusicPlayerState.shuffleChecker = !MusicPlayerState.shuffleChecker;
              widget._callback('shuffle', null);
            });
          };
          break;

        case ButtonMenuEnum.prev:
          wid = Icon(Icons.skip_previous, size: iconSize);
          func = (){
            setState(() {
              widget._callback('nextAndPrev', 'prev');
            });
          };
          break;

        case ButtonMenuEnum.play:
          wid = AnimatedIcon(
            icon: AnimatedIcons.pause_play,
            progress: _animatedIconController,
            size: iconSize * 1.5,
          );
          func = (){
            if (animatedIconControllerChecker){
              _animatedIconController.forward();
              PlatformMethodInvoker.pause();
            }else{
              _animatedIconController.reverse();
              print(sliderValue);
              sliderValue == 0
                  ? PlatformMethodInvoker.playFromCurrentQueueIndex(): PlatformMethodInvoker.play();
            }
            setState(() {
              animatedIconControllerChecker = !animatedIconControllerChecker;
            });
          };
          break;

        case ButtonMenuEnum.next:
          wid = Icon(Icons.skip_next, size: iconSize);
          func = (){
            setState(() {
              widget._callback('nextAndPrev', 'next');
            });
          };
          break;

        case ButtonMenuEnum.repeat:
          if (MusicPlayerState.repeatChecker == 0){
            wid = Transform.rotate(
              angle: 270 * pi / 180,
              child: Icon(
                Icons.vertical_align_bottom,
                size: iconSize * 0.75,
              ),
            );

          }else if (MusicPlayerState.repeatChecker == 1){
            wid = Icon(
                Icons.repeat,
                size: iconSize * 0.75,
            );
          }else if (MusicPlayerState.repeatChecker == 2){
            wid = Icon(
                Icons.repeat_one,
                size: iconSize * 0.75,
            );
          }

          func = (){
            setState(() {
              MusicPlayerState.repeatChecker = (MusicPlayerState.repeatChecker + 1) % 3;
            });
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
          ),
        ),
      );
    }
    return list;
  }

  /// Slider Settings
  Widget _slider(){
    return Column(
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
                    if (value > widget._music.duration.toDouble()){
                      sliderValue = widget._music.duration.toDouble();
                    }
                  });
                  PlatformMethodInvoker.seekTo(value.toInt());
                },
                value: sliderValue,
                max: widget._music.duration.toDouble(),
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
              Text(millSec2SecStr(nowSliderPosition)),
              Text(millSec2SecStr(widget._music.duration)),
            ],
          ),
        ),
      ],
    );
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
    if (list[i] != 0 || i == 0 || i == 1){
      res = res + list[i].toString().padLeft(2, "0");
      if (i != 0){
        res = res + ':';
      }
    }
  }
  return res;
}

///一巡するように並べ替える
List<dynamic> shuffleItems(List<dynamic> item){
  int len = item.length;
  List<dynamic> res = List.from(item);
  var list = new List<int>.generate(len, (i) => i);
  list.shuffle();

  for (int idx = 0; idx < len; idx++){
    res[list[idx]] = item[list[(idx+1) % len]];
  }
  return res;
}