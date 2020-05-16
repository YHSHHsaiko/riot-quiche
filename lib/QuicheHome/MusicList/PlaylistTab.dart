import 'package:flutter/material.dart';

import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Music/Album.dart';


class PlaylistTab extends StatefulWidget {
  final ValueNotifier<List<dynamic>> playlistTabValueNotifier;

  PlaylistTab (
    this.playlistTabValueNotifier, {Key key}
  ): super(key: key);
  
  @override
  _PlaylistTabState createState () {
    return _PlaylistTabState();
  }
}

class _PlaylistTabState extends State<PlaylistTab> {
  bool _isInitialized;
  dynamic listItem;
  SortType nowSortType = SortType.TITLE_ASC;

  static List<dynamic> _tmp = [];

  @override
  void initState () {
    super.initState();

    _isInitialized = false;
  }

  @override
  void dispose () {
    _tmp.add(listItem);

    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    print('size: $size');

    return FutureBuilder(
      future: _initialze(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || listItem == null) {
          return Center(child: FlutterLogo());
        }
        //
        return WillPopScope(
          onWillPop: () {
            if (_tmp.isEmpty) {
              Navigator.of(context).pop();
            } else {
              setState(() {
                listItem = _tmp.removeLast();
              });
            }
            
            return Future.value(false);
          },
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: _menu(),
              ),

              Expanded(
                child: ListView.separated(

                  itemBuilder: (BuildContext context, int index) {
                    if (index < listItem.length) {
                      return GestureDetector(
                        onTap: (){
                          if (listItem is Map) {
                            setState(() {
                              _tmp.add(listItem);
                              listItem = listItem[List.from(listItem.keys)[index]];
                              print('setState()::${listItem}');
                            });

                          } else if (listItem is List) {
                            print('$index');
                            widget.playlistTabValueNotifier.value = <dynamic>[listItem, index];

                            //TODO　ここでlistitemを全部追加
                            //callbuck側になにかkeyを渡して、特定の場所から始める。
                          }

                        },
                        child: _seclist(index, size),
                      );
                    } else {
                      return Divider(height: 100);
                    }
                  },
                  itemCount: listItem.length + 1,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(height: 1);
                  },
                ),
              ),
            ]
          )
        );
      }
    );
  }

  Future<Null> _initialze () async {
    if (!_isInitialized) {
      if (_tmp.isEmpty) {
        listItem = await QuicheOracleVariables.playlists;
      } else {
        listItem = _tmp.removeLast();
      }

      _isInitialized = true;
    }
  }

  Widget _menu(){
    return ListTile(
      title: Text(nowSortType.toString().split('.')[1]),
      trailing: PopupMenuButton<SortType>(
        onSelected: (SortType result) {
          setState(() {
            nowSortType = result;
            // listItem = QuicheOracleFunctions.getSortedMusicList(nowSortType);
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

  Widget _seclist(int index, Size size){
    Music m;
    String title;
    String artist;

    print(listItem);
    if (listItem is Map) {
      m = List.from(listItem.values)[0][index];
      title = List.from(listItem.keys)[0][index];
      artist = '';
    } else if (listItem is List) {
      m = listItem[index];
      title = listItem[index].title;
      artist = listItem[index].artist;
    }

    var jucketImage = m.getArt();
    if (jucketImage == null){
      jucketImage = Image.asset("images/dopper.jpg");
    }

//    var img = Image.network('https://pbs.twimg.com/media/EWm2AmcU4AID_2O?format=jpg&name=medium');
    var jacketSize = (size.height > size.width ? size.height: size.width) * 0.1;

    return Container(
      child: Row(
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                width: jacketSize,
                height: jacketSize,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: jucketImage.image,
                    )
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  height: jacketSize,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Expanded(
                        flex: 1,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: jacketSize / 4,
                          )
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          artist,
                          style: TextStyle(
                            fontSize: jacketSize / 6,
                          )
                        )
                      ),

                    ],
                  ),
                ),
              ),
            ),

          ]
      ),
    );

//    return Container(
//      child: ListTile(
//        leading: Container(
//          height: size.width * 0.1,
//          width: size.width * 0.1,
//          child: jucketImage,
//        ),
//        title: Text(listItem[index].title),
//        subtitle: Text(listItem[index].artist),
//        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueGrey,),
//      ),
//    );
  }
}