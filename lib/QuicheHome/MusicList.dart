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
      appBar: AppBar(title: Text('List Test')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
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
      jucketImage = iii.image;
      print('');
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black38),
        ),
      ),
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