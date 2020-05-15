import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/ExoPlayerPlaybackState.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicLayerSetting.dart';
import 'package:riot_quiche/QuicheHome/MusicList/MusicList.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/BackGround.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/Circle.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';
import 'package:riot_quiche/QuicheHome/Widgets/AutoScrollText.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';


enum ButtonMenuEnum{
  shuffle,
  prev,
  play,
  next,
  repeat,
}

class MusicPlayer extends StatefulWidget{
  final Size scSize;
  MusicPlayer(this.scSize);

  @override
  State<StatefulWidget> createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> with TickerProviderStateMixin {
  /// MusicPlayer Hard Cording
  double heightRateHeader = 0.1, heightRateFooter = 0.3;
  final imagePath = "images/dopper.jpg";

  /// MusicPlayer variables
  // controlls Animation
  AnimationController _controller;
  Animation<Offset> _offsetFooter, _offsetHeader, _offsetAnimation;
  var foldControllBar = false;

  /// Header
  double headerHeight;

  /// Footer
  AnimationController _animatedIconController;
  static bool animatedIconControllerChecker = true; //再生時：true, 停止時：false.

  // Controlls Buttons & Slider
  double sliderValue = 0;
  int nowSliderPosition = 0;


  // controlls Music
  Music _music;
  int nowPlayIndexOfQueue = 1;
  List<dynamic> musicList, moveIndexList;
  bool shuffleChecker = false;
  int repeatChecker = 0;

  // controlls Layers
  List<Widget> layers = [];
  List<Widget> mustLayers = [];
  static Size screenSize, longSize;
  double jacketSize;

  /// Others
  // none



  @override
  void initState() {
    super.initState();
    // size 関係
    screenSize = widget.scSize;
    jacketSize = (screenSize.width < screenSize.height ? screenSize.width : screenSize.height) * 0.6;
    longSize   = Size(screenSize.width, screenSize.height * 1.2);
    headerHeight = screenSize.height * 0.1;

    // controller 関係
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

    _animatedIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    PlatformMethodInvoker.redShift(this.forOnData);


    // TODO ここでPreference使って、曲データを参照する。
    // Set Initial Music.
    _setMusic([QuicheOracleVariables.musicList[0]], 0);

    // Index List For Shuffle.
    moveIndexList = List<dynamic>.generate(musicList.length, (i) => (i+1) % musicList.length);

    //TODO: foldControllBar を Shared Prefferenceで読み込む
    if (foldControllBar){
      _controller.reverse();
      print('reverse');
    }else {
      _controller.forward();
      print('forword');
    }


    // TODO :　仮で作っている表示用データ。この辺どうにかしないと
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
      )]
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  /// .
  // if pattern == shuffle => flag is bool
  // if pattern == nextAndPrev => flag is String
  void tapedFooterButton(String pattern, var flag){
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
          animatedIconControllerChecker = true;
        });
        break;
    }
  }



  /// for on date
  void forOnData(int position, int state){
    setState(() {
      sliderValue = position.toDouble();
      print(position.toDouble() > _music.duration.toDouble());
      if (position.toDouble() > _music.duration.toDouble()){
        sliderValue = 0; position = 0;
        if (repeatChecker == 0){ //その場で停止
          //何もしないで初期化
        }else if (repeatChecker == 1){ //ただ最初に戻る
          tapedFooterButton('nextAndPrev', 'next');
        }else if (repeatChecker == 2){ //曲を次のものにして最初に戻る。
          tapedFooterButton('nextAndPrev', 'unchanged');
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



  /// set music
  void _setMusic(dynamic music, int playIndex){
    animatedIconControllerChecker = true;

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
        tapedFooterButton('shuffle', null);
        PlatformMethodInvoker.setQueue(idList);
        PlatformMethodInvoker.setCurrentQueueIndex(nowPlayIndexOfQueue);
        PlatformMethodInvoker.playFromCurrentQueueIndex();
      });
    }
  }

  /// callback for layerSetting
  void callbackSetLayer(List<Widget> list){
    setState(() {
      print('set');
      layers = list;
    });
  }


  @override
  Widget build(BuildContext context) {
    Image returnsImageArt = _music.getArt();
    ImageProvider jacketImage = returnsImageArt == null ? AssetImage(imagePath) : returnsImageArt.image;

    mustLayers.clear();
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
          onPanUpdate: (pos) async {
            showDialog(
              context: context,
              builder: (_) {
                return MusicList(_music, nowPlayIndexOfQueue, onChangedCallback: _setMusic);
              },
            );

          },
          child: Container(
            height: screenSize.height,
            width: screenSize.width,
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
                    height: screenSize.height * heightRateHeader,
                    child: MusicPlayerHeader(),
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
                    height: screenSize.height * heightRateFooter,
                    child: MusicPlayerFooter(),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


  /// MusicPlayerHeader ///
  Widget MusicPlayerHeader(){
    return Row(
      children: <Widget>[
        // Leading Icon
        SizedBox(
          width: headerHeight,
          child: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              print('more_vert');
            },
          ),
        ),

        // AutoScrollText
        SizedBox(
          height: headerHeight,
          width: screenSize.width - 2 * headerHeight,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: headerHeight,
                child: AutoScrollText(
                  text: _music.title,
                  textStyle: TextStyle(fontSize: headerHeight / 2.5),
                ),
              ),
            ],
          ),
        ),

        // Trailing Icon
        SizedBox(
          width: headerHeight,
          child: IconButton(
            icon: Icon(Icons.layers),
            onPressed: () {
              print('layers');
              showDialog(
                context: context,
                builder: (_) {
                  return MusicLayerSetting(callbackSetLayer, layers, MusicPlayerState.screenSize);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// MusicPlayerFooter ///
  Widget MusicPlayerFooter(){
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
            color: shuffleChecker ? Colors.black : Colors.grey,
          );
          func = (){
            setState(() {
              shuffleChecker = !shuffleChecker;
              tapedFooterButton('shuffle', null);
            });
          };
          break;

        case ButtonMenuEnum.prev:
          wid = Icon(Icons.skip_previous, size: iconSize);
          func = (){
            setState(() {
              tapedFooterButton('nextAndPrev', 'prev');
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
              tapedFooterButton('nextAndPrev', 'next');
            });
          };
          break;

        case ButtonMenuEnum.repeat:
          if (repeatChecker == 0){
            wid = Transform.rotate(
              angle: 270 * pi / 180,
              child: Icon(
                Icons.vertical_align_bottom,
                size: iconSize * 0.75,
              ),
            );

          }else if (repeatChecker == 1){
            wid = Icon(
                Icons.repeat,
                size: iconSize * 0.75,
            );
          }else if (repeatChecker == 2){
            wid = Icon(
                Icons.repeat_one,
                size: iconSize * 0.75,
            );
          }

          func = (){
            setState(() {
              repeatChecker = (repeatChecker + 1) % 3;
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
                    if (value > _music.duration.toDouble()){
                      sliderValue = _music.duration.toDouble();
                    }
                  });
                  PlatformMethodInvoker.seekTo(value.toInt());
                },
                value: sliderValue,
                max: _music.duration.toDouble(),
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
              Text(millSec2SecStr(_music.duration)),
            ],
          ),
        ),
      ],
    );
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
