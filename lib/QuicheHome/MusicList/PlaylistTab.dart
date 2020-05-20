import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/PopupMenuEnum.dart';

import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/Music/Playlist.dart';
import 'package:riot_quiche/QuicheHome/MusicList/PopupMenu/PopupMenuForAddToPlaylist.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Music/Album.dart';


class PlaylistTab extends StatefulWidget {
  final ValueNotifier<List<dynamic>> playlistTabValueNotifier;
  final ValueNotifier<List<dynamic>> onPlaylistChangedNotifier;

  PlaylistTab (
    this.playlistTabValueNotifier,
    {
      Key key,
      @required this.onPlaylistChangedNotifier
    }
  ): super(key: key);
  
  @override
  _PlaylistTabState createState () {
    return _PlaylistTabState();
  }
}

class _PlaylistTabState extends State<PlaylistTab> with AutomaticKeepAliveClientMixin {
  //
  bool wantKeepAlive = true;
  //
  dynamic listItem;
  SortType nowSortType = SortType.TITLE_ASC;

  static String _playlistIdentifier;

  @override
  void initState () {
    super.initState();

    widget.onPlaylistChangedNotifier.addListener(() {
      setState(() {
        
      });
    });
  }

  @override
  void dispose () {
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
            if (_playlistIdentifier == null) {
              Navigator.of(context).pop();
            } else {
              setState(() {
                _playlistIdentifier = null;
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
                          if (listItem[index] is Playlist) {
                            setState(() {
                              _playlistIdentifier = listItem[index].name;
                              listItem = listItem[index].musics;
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
    if (_playlistIdentifier == null) {
      // this block is executed when listItem is the list of "Playlist".
      listItem = await Playlist.playlists;
    } else {
      // this block is executed when listItem is the list of "Music".
      listItem = (await Playlist.fromName(_playlistIdentifier)).musics;
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
    Image jucketImage;

    print(listItem);
    if (listItem[index] is Playlist) {
      Playlist targetPlaylist = listItem[index];
      if (targetPlaylist.musics.isEmpty) {
        jucketImage = Image.asset("images/dopper.jpg");
        artist = '0 Musics';
      } else {
        m = targetPlaylist.musics[0];
        jucketImage = m.getArt();
        if (jucketImage == null) {
          jucketImage = Image.asset("images/dopper.jpg");
        }
        artist = '${targetPlaylist.musics.length} Musics';
      }
      title = targetPlaylist.name;
    } else if (listItem is List) {
      m = listItem[index];
      jucketImage = m.getArt();
      if (jucketImage == null) {
        jucketImage = Image.asset("images/dopper.jpg");
      }
      title = listItem[index].title;
      artist = listItem[index].artist;
    }

//    var img = Image.network('https://pbs.twimg.com/media/EWm2AmcU4AID_2O?format=jpg&name=medium');
    var jacketSize = (size.height > size.width ? size.height: size.width) * 0.1;

    Widget popupMenu;
    if (listItem[index] is Playlist) {
      popupMenu = Container();
    } else if (listItem is List) {
      popupMenu = PopupMenuButton<PopupMenuEnum>(
        onSelected: (PopupMenuEnum popupMenu) async {
          switch (popupMenu) {
            case PopupMenuEnum.AddToPlaylist: {
              await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 250, maxHeight: 400
                      ),
                      child: PopupMenuForAddToPlaylist(m)
                    )
                  );
                }
              );

              widget.onPlaylistChangedNotifier.value = <dynamic>[];
            }
          }
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<PopupMenuEnum>>[
            const PopupMenuItem<PopupMenuEnum>(
              value: PopupMenuEnum.AddToPlaylist,
              child: Text('Add to playlist')
            )
          ];
        }
      );
    }

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
            popupMenu
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