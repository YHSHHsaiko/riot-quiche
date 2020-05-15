import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'package:riot_quiche/header.dart';
import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Album.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheHome/MusicList/VariousSortTab.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayer.dart';
import 'package:riot_quiche/QuicheOracle.dart';


class MusicList extends StatefulWidget{
  final Music nowPlaying;
  final int playIndex;
  final OnMusicChangedCallback onChangedCallback;

  MusicList(this.nowPlaying, this.playIndex, {@required this.onChangedCallback});

  @override
  State<StatefulWidget> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> with TickerProviderStateMixin {
  List<dynamic> listItem = [], tmp = [];
  SortType nowSortType = SortType.TITLE_ASC;
  int playIndex;
  // tsuchida
  bool _isNowPlayingChanged;
  TabController _tabController;
  ValueNotifier<List<dynamic>> onMusicChangedNotifier;
  //

  @override
  void initState() {
    //TODO ここでソートのタイプを読み取っておいて、それに適したものを取得する。
    super.initState();

    listItem = QuicheOracleFunctions.getSortedMusicList(nowSortType);
    playIndex = widget.playIndex;
    // tsuchida
    _tabController = TabController(length: 2, vsync: this);
    onMusicChangedNotifier = ValueNotifier<List<dynamic>>(null)
    ..value = <dynamic>[listItem, playIndex]
    ..addListener(() {
      // listItem = onMusicChangedNotifier.value[0];
      // playIndex = onMusicChangedNotifier.value[1];

      widget.onChangedCallback(onMusicChangedNotifier.value[0], onMusicChangedNotifier.value[1] as int);
      _isNowPlayingChanged = true;

      print('ValueNotifier::onListener');
    });

    _isNowPlayingChanged = false;
    //
  }

  @override
  void dispose () {
    onMusicChangedNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: <Widget>[
          VariousSortTab(listItem, onMusicChangedNotifier),
          Align(
            alignment: Alignment.bottomCenter,
            child: SubPlayer(widget.nowPlaying, onMusicChangedNotifier),
          ),
        ],
      ),
    );
  }
}




class SubPlayer extends StatefulWidget {
  final Music nowPlaying;
  final ValueNotifier onMusicChangedNotifier;

  SubPlayer(this.nowPlaying, this.onMusicChangedNotifier);

  @override
  State<StatefulWidget> createState() => _SubPlayerState();
}


class _SubPlayerState extends State<SubPlayer> with SingleTickerProviderStateMixin{
  Size screenSize;
  String imagePath = "images/dopper.jpg";
  AnimationController _animatedIconController;
  bool isPlaying;
  Music nowPlaying;

  @override
  void initState() {
    super.initState();

    _animatedIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (!MusicPlayerState.animatedIconControllerChecker){
      setState(() {
        _animatedIconController.forward();
      });
    }

    widget.onMusicChangedNotifier.addListener(() {
      setState(() {
        nowPlaying = widget.onMusicChangedNotifier.value[0][widget.onMusicChangedNotifier.value[1]];
      });
    });

    nowPlaying = widget.nowPlaying;
  }

  @override
  void dispose() {
    _animatedIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    var iii = nowPlaying.getArt();
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
              child: Text(nowPlaying.title)
            ),

            Expanded(
              flex: 15,
              child: FlatButton(
                onPressed: () {
                  widget.onMusicChangedNotifier.value = <dynamic>[
                    widget.onMusicChangedNotifier.value[0],
                    _changePlayIndex(widget.onMusicChangedNotifier.value[1] as int, -1)
                  ];
                },
                child: Icon(Icons.skip_previous)
              )
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
              child: FlatButton(
                onPressed: () {
                  widget.onMusicChangedNotifier.value = <dynamic>[
                    widget.onMusicChangedNotifier.value[0],
                    _changePlayIndex(widget.onMusicChangedNotifier.value[1] as int, 1)
                  ];
                },
                child: Icon(Icons.skip_next)
              )
            ),
          ],
        ),
      ),
    );
  }

  int _changePlayIndex (int currentIndex, int changeAmount) {
    int changedIndex = currentIndex + changeAmount;

    if (changedIndex > widget.onMusicChangedNotifier.value[0].length) {
      changedIndex = widget.onMusicChangedNotifier.value[0].length;
    } else if (changedIndex < 0) {
      changedIndex = 0;
    }

    return changedIndex;
  }

}