import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:riot_quiche/QuicheHome/MusicList/PlaylistTab.dart';

import 'package:riot_quiche/header.dart';
import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Album.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheHome/MusicList/VariousSortTab.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayer.dart';
import 'package:riot_quiche/QuicheOracle.dart';


class MusicList extends StatefulWidget{
  final List<dynamic> musicList;
  final int playIndex;
  final OnMusicChangedCallback onChangedCallback;

  MusicList(
    this.musicList, this.playIndex,
    {
      @required this.onChangedCallback
    }
  );

  @override
  State<StatefulWidget> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> with TickerProviderStateMixin {
  int playIndex;
  // tsuchida
  ValueNotifier<List<dynamic>> onMusicChangedNotifier;
  ValueNotifier<List<dynamic>> onPlaylistChangedNotifier;
  ValueNotifier<List<dynamic>> onVariousSortTabWillPopNotifier;
  ValueNotifier<List<dynamic>> onPlaylistTabWillPopNotifier;

  List<ValueNotifier<List<dynamic>>> _willPopNotifiers;
  List<Tab> _tabs;
  TabController _tabController;

  static int _initialPage = 0;
  //

  @override
  void initState() {
    //TODO ここでソートのタイプを読み取っておいて、それに適したものを取得する。
    super.initState();

    playIndex = widget.playIndex;
    // tsuchida
    onMusicChangedNotifier = ValueNotifier<List<dynamic>>(<dynamic>[widget.musicList, playIndex])
    ..addListener(() {
      
      onMusicChangedNotifier.value[1] = widget.onChangedCallback(
        (onMusicChangedNotifier.value[0] is List)
          ? onMusicChangedNotifier.value[0] : [onMusicChangedNotifier.value[0]],
        onMusicChangedNotifier.value[1] as int
      );

      print('ValueNotifier::onListener');
    });

    onPlaylistChangedNotifier = ValueNotifier<List<dynamic>>(<dynamic>[]);

    onVariousSortTabWillPopNotifier = ValueNotifier<List<dynamic>>(null);

    onPlaylistTabWillPopNotifier = ValueNotifier<List<dynamic>>(null);

    _willPopNotifiers = <ValueNotifier<List<dynamic>>>[
      onVariousSortTabWillPopNotifier,
      onPlaylistTabWillPopNotifier
    ];
    _tabs = <Tab>[
      Tab(
        child: VariousSortTab(
          onMusicChangedNotifier,
          onPlaylistChangedNotifier: onPlaylistChangedNotifier,
          onWillPopNotifier: onVariousSortTabWillPopNotifier
        )
      ),
      Tab(
        child: PlaylistTab(
          onMusicChangedNotifier,
          onPlaylistChangedNotifier: onPlaylistChangedNotifier,
          onWillPopNotifier: onPlaylistTabWillPopNotifier
        )
      )
    ];

    _tabController = TabController(initialIndex: _initialPage, length: 2, vsync: this)
    ..addListener(() {
      print('currentPage: ${_tabController.index}');
      _initialPage = _tabController.index;
    });

    //
  }

  @override
  void dispose () {
    print('MusicList::dispose()');
    onMusicChangedNotifier.dispose();
    onPlaylistChangedNotifier.dispose();
    onVariousSortTabWillPopNotifier.dispose();
    onPlaylistTabWillPopNotifier.dispose();

    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        bool shouldPop = _willPopNotifiers[_tabController.index].value[0];
        
        if (shouldPop) {
          Navigator.of(context).pop();
        } else {
          _willPopNotifiers[_tabController.index].value = <dynamic>[true];
        }

        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select Music'),
          bottom: PreferredSize(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: <Tab>[
                const Tab(
                  text: 'Library'
                ),
                const Tab(
                  text: 'Playlist'
                )
              ]
            ),
            preferredSize: Size.fromHeight(30.0)
          ),
        ),
        body: Stack(
          children: <Widget>[
            TabBarView(
              controller: _tabController,
              children: _tabs
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SubPlayer(widget.musicList[playIndex], onMusicChangedNotifier),
            )
          ]
        )
      )
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
                    widget.onMusicChangedNotifier.value[1] - 1
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
                    widget.onMusicChangedNotifier.value[1] + 1
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

}