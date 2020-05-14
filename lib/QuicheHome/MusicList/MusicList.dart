import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Album.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheHome/MusicList/VariousSortTab.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayer.dart';
import 'package:riot_quiche/QuicheOracle.dart';

class MusicList extends StatefulWidget{
  MusicList(this.nowPlaying);
  final Music nowPlaying;

  @override
  State<StatefulWidget> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> with TickerProviderStateMixin {
  List<dynamic> listItem = [], tmp = [];
  SortType nowSortType = SortType.TITLE_ASC;
  int playIndex;
  int nowLayer;
  // tsuchida
  bool _isNowPlayingChanged;
  TabController _tabController;
  ValueNotifier<List<dynamic>> variousTabValueNotifier;
  //

  @override
  void initState() {
    //TODO ここでソートのタイプを読み取っておいて、それに適したものを取得する。
    super.initState();

    nowLayer = 0;
    listItem = QuicheOracleFunctions.getSortedMusicList(nowSortType);
    // tsuchida
    _tabController = TabController(length: 2, vsync: this);
    variousTabValueNotifier = ValueNotifier<List<dynamic>>(null)
    ..addListener(() {
      listItem = variousTabValueNotifier.value[0];
      playIndex = variousTabValueNotifier.value[1];
      nowLayer = variousTabValueNotifier.value[2];

      _isNowPlayingChanged = true;
    });

    _isNowPlayingChanged = false;
    //
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        bool override = true;
        if (nowLayer == 0){
          if (_isNowPlayingChanged) {
            Navigator.of(context).pop(<dynamic>[listItem, playIndex]);
          } else {
            Navigator.of(context).pop(null);
          }
        }else if (nowLayer == 1){
          override = false;
          setState(() {
            listItem = tmp;
            nowLayer--;
          });
        }
        return new Future<bool>.value(override);
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            VariousSortTab(listItem, variousTabValueNotifier),
            Align(
              alignment: Alignment.bottomCenter,
              child: SubPlayer(widget.nowPlaying),
            ),
          ],
        ),
      ),
    );
  }
}




class SubPlayer extends StatefulWidget {
  SubPlayer(this.nowPlaying);
  final nowPlaying;

  @override
  State<StatefulWidget> createState() => SubPlayerState();
}


class SubPlayerState extends State<SubPlayer> with SingleTickerProviderStateMixin{
  Size screenSize;
  String imagePath = "images/dopper.jpg";
  AnimationController _animatedIconController;
  bool isPlaying;

  @override
  void initState() {
    _animatedIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (!MusicPlayerState.animatedIconControllerChecker){
      setState(() {
        _animatedIconController.forward();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _animatedIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;



    var iii = widget.nowPlaying.getArt();
    var jucketImage;
    if (iii == null){
      jucketImage = AssetImage(imagePath);
    }else{
      jucketImage = iii.image;
    }

    return GestureDetector(
      onTap: (){
        Navigator.of(context).pop();
      },
      child: Card(
        color: Colors.blueGrey,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 20,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  height: screenSize.width * 0.15,
                  width: screenSize.width * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: jucketImage,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 40,
              child: Text(widget.nowPlaying.title)
            ),

            Expanded(
              flex: 15,
              child: Icon(Icons.skip_previous)
            ),


            Expanded(
              flex: 15,
              child: RawMaterialButton(

                child: AnimatedIcon(
                  icon: AnimatedIcons.pause_play,
                  progress: _animatedIconController,
                ),
                onPressed: () {
                  setState(() {
                    if (MusicPlayerState.animatedIconControllerChecker){
                      PlatformMethodInvoker.pause();
                      _animatedIconController.forward();
                    }else{
                      PlatformMethodInvoker.play();
                      _animatedIconController.reverse();
                    }
                    MusicPlayerState.animatedIconControllerChecker = !MusicPlayerState.animatedIconControllerChecker;
                  });
                },
              ),
            ),

            Expanded(
              flex: 15,
              child: Icon(Icons.skip_next)
            ),
          ],
        ),
      ),
    );
  }


}