import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayer.dart';
import 'package:riot_quiche/QuicheOracle.dart';

class MusicList extends StatefulWidget{
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
                    Navigator.pushReplacement(
                      context,
                      new MaterialPageRoute<Null>(
                        settings: const RouteSettings(name: "/musicPlayer"),
                        builder: (BuildContext context) => MusicPlayer("newplay$index", listItem[index]),
                      ),
                    );
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
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black38),
        ),
      ),
      child: ListTile(
        leading: Hero(
          tag: "newplay$index",
          child: Container(
            height: size.width * 0.1,
            width: size.width * 0.1,
            child: Image.asset("images/dopper.jpg"),//Image.file(File.fromUri(Uri.file(listItem[index].artUri)))
          ),
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
        Navigator.push(
          context,
          new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: "/musicPlayer"),
            builder: (BuildContext context) => MusicPlayer("playnow", null),
          ),
        );
      },
      child: Container(
        color: Colors.amber,
        child: Row(
          children: <Widget>[
            Hero(
              tag: "playnow",
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }

}