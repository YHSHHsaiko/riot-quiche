import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Album.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayer.dart';
import 'package:riot_quiche/QuicheOracle.dart';

class MusicList extends StatefulWidget{
  MusicList(this.callback, this.nowPlaying);
  final callback;
  final Music nowPlaying;


  @override
  State<StatefulWidget> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  List<dynamic> listItem = [], tmp = [];
  SortType nowSortType = SortType.TITLE_ASC;

  @override
  void initState() {
    //TODO ここでソートのタイプを読み取っておいて、それに適したものを取得する。
    listItem = QuicheOracleFunctions.getSortedMusicList(nowSortType);
    super.initState();
  }

  void callbackList(BuildContext con){
    Navigator.of(context).pop();
  }

  int nowLayer = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        bool override = true;
        if (nowLayer == 0){
          Navigator.of(context).pop();
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
        body: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: menu(size),
            ),

            Expanded(
              child: ListView.separated(

                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: (){
                      if (listItem[index] is Album){
                        setState(() {
                          tmp = listItem;
                          listItem = listItem[index].musics;
                          nowLayer++;
                        });
                      }else{
                        print('$index');
//                        widget.callback(listItem[index]);
                        widget.callback(listItem, index);
                        Navigator.of(context).pop();

                        //TODO　ここでlistitemを全部追加
                        //callbuck側になにかkeyを渡して、特定の場所から始める。

                      }

                    },
                    child: seclist(index, size),
                  );},
                itemCount: listItem.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(height: 1);
                },
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SubPlayer(widget.nowPlaying),
            ),
          ],
        ),
      ),
    );
  }

  Widget menu(Size size){
    return ListTile(
      title: Text(nowSortType.toString().split('.')[1]),
      trailing: PopupMenuButton<SortType>(
        onSelected: (SortType result) {
          setState(() {
            nowSortType = result;
            listItem = QuicheOracleFunctions.getSortedMusicList(nowSortType);
          });
        },
        itemBuilder: (BuildContext context) {
          return SortType.values.map((SortType st) {
            return PopupMenuItem<SortType>(
              value: st,
              child: Text(st.toString()),
            );
          }).toList();
        },
      ),
    );

  }

  Widget seclist(int index, Size size){
    var m = listItem[index];
    var jucketImage = m.getArt();
    if (jucketImage == null){
      jucketImage = Image.asset("images/dopper.jpg");
    }

    return Container(
      child: ListTile(
        leading: Container(
          height: size.width * 0.1,
          width: size.width * 0.1,
          child: jucketImage,
        ),
        title: Text(listItem[index].title),
        subtitle: Text(listItem[index].artist),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueGrey,),
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

    if (!MusicPlayerFooterState.animatedIconControllerChecker){
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
                    if (MusicPlayerFooterState.animatedIconControllerChecker){
                      PlatformMethodInvoker.pause();
                      _animatedIconController.forward();
                    }else{
                      PlatformMethodInvoker.play();
                      _animatedIconController.reverse();
                    }
                    MusicPlayerFooterState.animatedIconControllerChecker = !MusicPlayerFooterState.animatedIconControllerChecker;
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