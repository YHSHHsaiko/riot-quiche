import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayer.dart';
import 'package:riot_quiche/QuicheOracle.dart';

class MusicList extends StatefulWidget{
  MusicList(this.callback);
  final callback;

  @override
  State<StatefulWidget> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  List<Music> listItem = [];

  @override
  void initState() {
    listItem = QuicheOracleVariables.musicList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(

              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: (){
                    print('$index');
                    widget.callback(listItem[index]);
                    Navigator.of(context).pop();
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
            child: subPlayer(size),
          ),
        ],
      ),
    );
  }

  Widget seclist(int index, Size size){
    Music m = listItem[index];
    var iii = m.getArt();
    var jucketImage;
    if (iii == null){
      jucketImage = Image.asset("images/dopper.jpg");
      print('null');
    } else {
      jucketImage = iii;
      print('');
    }

    return Container(
      child: ListTile(
        leading: Container(
          height: size.width * 0.1,
          width: size.width * 0.1,
          child: jucketImage,
//            child: Image.asset("images/dopper.jpg"),//Image.file(File.fromUri(Uri.file(listItem[index].artUri)))
        ),
        title: Text(listItem[index].title),
        subtitle: Text(listItem[index].album),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget subPlayer(Size size){
    var imagePath = "images/dopper.jpg";

    return GestureDetector(
      onTap: (){
        print('sub');
        Navigator.of(context).pop();
      },
      child: Container(
        color: Colors.amber,
        child: Row(
          children: <Widget>[
            Container(
              height: size.width * 0.2,
              width: size.width * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(imagePath),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}