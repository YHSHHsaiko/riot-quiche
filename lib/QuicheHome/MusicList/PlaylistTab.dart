import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/PopupMenuEnum.dart';

import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/Music/Playlist.dart';
import 'package:riot_quiche/QuicheAssets.dart';
import 'package:riot_quiche/QuicheHome/MusicList/PopupMenu/PopupMenuForAddToPlaylist.dart';
import 'package:riot_quiche/QuicheHome/MusicList/PopupMenu/PopupMenuForRemovePlaylist.dart';
import 'package:riot_quiche/QuicheHome/Widgets/AutoScrollText.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Music/Album.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PlaylistTab extends StatefulWidget {
  final ValueNotifier<List<dynamic>> playlistTabValueNotifier;
  final ValueNotifier<List<dynamic>> onPlaylistChangedNotifier;
  final ValueNotifier<List<dynamic>> onWillPopNotifier;

  PlaylistTab (
    this.playlistTabValueNotifier,
    {
      Key key,
      @required this.onPlaylistChangedNotifier,
      @required this.onWillPopNotifier
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
  static SortType nowSortType = SortType.TITLE_ASC;

  String _playlistIdentifier;
  bool _isInitialized;

  ScrollController _reorderScrollController;

  bool isPlaylist;

  bool editMode;

  @override
  void initState () {
    super.initState();

    _isInitialized = false;
    isPlaylist = true;
    editMode = false;

    _reorderScrollController = ScrollController();

    widget.onPlaylistChangedNotifier.addListener(() {
      setState(() {
        
      });
    });
  }

  @override
  void dispose () {
    _reorderScrollController.dispose();

    _destruct();

    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    super.build(context);

    final Size size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: _initialze(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || listItem == null) {
          return Center(child: FlutterLogo());
        }
        //

        Widget listView;
        if (listItem.isEmpty || listItem[0] is Playlist) {
          isPlaylist = true;
          editMode = false;
          //
        } else {
          isPlaylist = false;
          //
        }

        if (editMode) {
          listView = EditPlaylistView(
            _playlistIdentifier,
            listItem,
            scrollController: _reorderScrollController,
            childBuilder: (int index) => _seclist(index, size),
          );
        } else {
          listView = ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              if (index < listItem.length) {
                return FlatButton(
                  onPressed: () {
                    widget.onWillPopNotifier.value = <dynamic>[false, index];

                    //TODO　ここでlistitemを全部追加
                    //callbuck側になにかkeyを渡して、特定の場所から始める。
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
            }
          );
        }

        return Scaffold(
          backgroundColor: editMode ? Colors.blue.withAlpha(30) : Colors.white,
          body: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: _menu(),
              ),

              Expanded(
                child: listView
              )
            ]
          )
        );
      }
    );
  }

  Future<Null> _initialze () async {
    print('_initialize::_playlistIdentifier: ${_playlistIdentifier}');

    if (!_isInitialized) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('playlistTab::_playlistIdentifier')) {
        _playlistIdentifier = prefs.getString('playlistTab::_playlistIdentifier');

        if (_playlistIdentifier == null) {
          widget.onWillPopNotifier.value = <dynamic>[true];
        } else {
          widget.onWillPopNotifier.value = <dynamic>[false];
        }
      } else {
        widget.onWillPopNotifier.value = <dynamic>[true];
      }

      widget.onWillPopNotifier.addListener(() {
        bool shouldPop = widget.onWillPopNotifier.value[0];

        if (shouldPop) {
          setState(() {
            _playlistIdentifier = null;
          });
        } else {
          int index = widget.onWillPopNotifier.value[1];

          if (listItem[index] is Playlist) {
            _playlistIdentifier = listItem[index].name;

            setState(() {
              listItem = listItem[index].musics;
            });
            print('setState()::${listItem}');
            print(_playlistIdentifier);
          } else if (listItem is List) {
            print('$index');
            widget.playlistTabValueNotifier.value = <dynamic>[listItem, index];
          }
        }
      });

      _isInitialized = true;
    }

    if (_playlistIdentifier == null) {
      // this block is executed when listItem is the list of "Playlist".
      listItem = await Playlist.playlists;
      listItem.sort((Playlist p1, Playlist p2) {
        if (nowSortType == SortType.TITLE_ASC) {
          return p1.name.compareTo(p2.name);
        } else if (nowSortType == SortType.TITLE_DESC) {
          return p2.name.compareTo(p1.name);
        } else {
          return 0;
        }
      });
    } else {
      // this block is executed when listItem is the list of "Music".
      listItem = (await Playlist.fromName(_playlistIdentifier)).musics;
    }
  }

  Future<Null> _destruct () async {
    print('_initialize::_playlistIdentifier: ${_playlistIdentifier}');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('playlistTab::_playlistIdentifier', _playlistIdentifier);
  }

  Widget _menu(){
    if (isPlaylist) {
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
            return <PopupMenuEntry<SortType>>[
              PopupMenuItem<SortType>(
                value: SortType.TITLE_ASC,
                child: Text(SortType.TITLE_ASC.toString())
              ),
              PopupMenuItem<SortType>(
                value: SortType.TITLE_DESC,
                child: Text(SortType.TITLE_DESC.toString())
              )
            ];
          },
        ),
      );
    } else {
      if (editMode) {
        return Container(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: FlatButton(
              onPressed: () {
                setState(() {
                  editMode = false;
                });
              },
              color: Colors.red[200],
              child: Icon(Icons.check)
            )
          )
        );
      } else {
        return Container(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: FlatButton(
              onPressed: () {
                setState(() {
                  editMode = true;
                });
              },
              color: Colors.blue,
              child: const Text(
                'Edit Playlist',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              )
            )
          )
        );
      }
    }
  }

  Widget _seclist(int index, Size size){
    Music m;
    String title;
    String artist;
    Image jucketImage;

    print(listItem);
    if (isPlaylist) {
      Playlist targetPlaylist = listItem[index];
      if (targetPlaylist.musics.isEmpty) {
        jucketImage = QuicheAssets.icon;
        artist = '0 Musics';
      } else {
        m = targetPlaylist.musics[0];
        jucketImage = m.getArt();
        if (jucketImage == null) {
          jucketImage = QuicheAssets.icon;
        }
        artist = '${targetPlaylist.musics.length} Musics';
      }
      title = targetPlaylist.name;
    } else {
      m = listItem[index];
      jucketImage = m.getArt();
      if (jucketImage == null) {
        jucketImage = QuicheAssets.icon;
      }
      title = listItem[index].title;
      artist = listItem[index].artist;
    }

    var jacketSize = (size.height > size.width ? size.height: size.width) * 0.1;

    Widget popupMenu;
    if (editMode) {
      popupMenu = Container();
    } else {
      if (isPlaylist) {
        popupMenu = PopupMenuButton<PopupMenuEnum>(
          onSelected: (PopupMenuEnum popupMenu) async {
            switch (popupMenu) {
              case PopupMenuEnum.RemovePlaylist: {
                await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 250, maxHeight: 200
                        ),
                        child: PopupMenuForRemovePlaylist(listItem[index])
                      )
                    );
                  }
                );

                widget.onPlaylistChangedNotifier.value = <dynamic>[];

                break;
              }
              default: break;
            }
          },
          itemBuilder: (BuildContext context) {
            return const <PopupMenuEntry<PopupMenuEnum>>[
              const PopupMenuItem<PopupMenuEnum>(
                value: PopupMenuEnum.RemovePlaylist,
                child: const Text('Remove playlist')
              )
            ];
          }
        );
      } else {
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

                break;
              }
              default: break;
            }
          },
          itemBuilder: (BuildContext context) {
            return const <PopupMenuEntry<PopupMenuEnum>>[
              const PopupMenuItem<PopupMenuEnum>(
                value: PopupMenuEnum.AddToPlaylist,
                child: const Text('Add to playlist')
              )
            ];
          }
        );
      }
    }

    return Container(
      height: jacketSize + 4.0,
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
                        child: AutoScrollText(
                          text: title,
                          textStyle: TextStyle(
                            fontSize: jacketSize / 4,
                          )
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: AutoScrollText(
                          text: artist,
                          textStyle: TextStyle(
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
  }
}


class EditPlaylistView extends StatefulWidget {
  final String playlistIdentifier;
  final listItem;
  final ScrollController scrollController;
  final Widget Function(int) childBuilder;

  EditPlaylistView (
    this.playlistIdentifier,
    this.listItem,
    {
      @required this.scrollController,
      @required this.childBuilder
    }
  );

  @override
  _EditPlaylistViewState createState() {
    // TODO: implement createState
    return _EditPlaylistViewState();
  }
}

class _EditPlaylistViewState extends State<EditPlaylistView> {
  List<Music> listItem;

  @override
  void initState () {
    super.initState();

    listItem = widget.listItem;
  }

  @override
  Widget build (BuildContext context) {
    return ReorderableListView(
      scrollController: widget.scrollController,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          
          Music item = listItem.removeAt(oldIndex);
          listItem.insert(newIndex, item);
          Playlist(widget.playlistIdentifier, listItem).save();
        });
      },
      children: List.generate(widget.listItem.length+1, (int index) {
        if (index < widget.listItem.length) {
          return FlatButton(
            key: Key(index.toString()),
            onPressed: () => null,
            child: widget.childBuilder(index)
          );
        } else {
          return Divider(key: Key(index.toString()), height: 100);
        }
      })
    );
  }
}