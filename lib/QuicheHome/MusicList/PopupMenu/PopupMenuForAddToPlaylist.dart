import 'package:flutter/material.dart';
import 'package:riot_quiche/Music/Album.dart';
import 'package:riot_quiche/Music/Playlist.dart';

import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PopupMenuForAddToPlaylist extends StatefulWidget {
  final Music targetMusic;

  PopupMenuForAddToPlaylist (this.targetMusic);

  @override
  _PopupMenuForAddToPlaylistState createState () {
    return _PopupMenuForAddToPlaylistState();
  }
}

class _PopupMenuForAddToPlaylistState extends State<PopupMenuForAddToPlaylist> {
  List<Playlist> _playlists;
  ValueNotifier<String> onPlaylistInputValueNotifier;
  //

  @override
  void initState () {
    super.initState();

    onPlaylistInputValueNotifier = ValueNotifier<String>(null)
    ..addListener(() {
      setState(() {
        Playlist newPlaylist = Playlist(onPlaylistInputValueNotifier.value, [])
        ..save();
        _playlists.add(newPlaylist);
      });
      print('update playlists::${_playlists}');
    });
  }

  @override
  void dispose () {
    onPlaylistInputValueNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: FutureBuilder(
        future: _initialize(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.none: {
              return Center(child: FlutterLogo());
              break;
            }
            case ConnectionState.done: {
              if (snapshot.hasError) {
                return Center(child: FlutterLogo());
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _PlaylistInput(
                        List<String>.from(_playlists.map((Playlist playlist) => playlist.name)),
                        onPlaylistInputValueNotifier: onPlaylistInputValueNotifier
                      )
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 3 / 4,
                        child: ListView(
                          children: <Widget>[
                            for (int i = 0; i < _playlists.length; ++i) _PlaylistCell(
                              _playlists[i],
                              widget.targetMusic
                            ),
                            Container(
                              height: 50.0
                            )
                          ]
                        )
                      )
                    )
                  ]
                );
              }
              break;
            }
          }
        }
      )
    );
  }

  Future<Null> _initialize () async {
    _playlists = await Playlist.playlists;
  }
}

//
class _PlaylistInput extends StatefulWidget {
  final List<String> playlistNames;
  final ValueNotifier<String> onPlaylistInputValueNotifier;


  _PlaylistInput (this.playlistNames, {@required this.onPlaylistInputValueNotifier});

  @override
  _PlaylistInputState createState () {
    return _PlaylistInputState();
  }
}

class _PlaylistInputState extends State<_PlaylistInput> {
  TextEditingController _textEditingController;
  String _addedPlaylistName;
  
  @override
  void initState () {
    super.initState();

    _textEditingController = TextEditingController();
  }

  @override
  Widget build (BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: FlatButton(
            onPressed: () {
              if (!widget.playlistNames.contains(_addedPlaylistName)) {
                widget.onPlaylistInputValueNotifier.value = _addedPlaylistName;
              }
            },
            child: Icon(Icons.exposure_plus_1)
          )
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _textEditingController,
              onChanged: (String changedString) {
                _addedPlaylistName = changedString;
              }
            )
          )
        )
      ]
    );
  }
}

//
class _PlaylistCell extends StatefulWidget {
  final Playlist playlist;
  final Music targetMusic;

  _PlaylistCell (this.playlist, this.targetMusic);

  @override
  _PlaylistCellState createState () {
    return _PlaylistCellState();
  }
}

class _PlaylistCellState extends State<_PlaylistCell> {
  ValueNotifier<bool> onCheckBoxChangedNotifier;

  @override
  void initState () {
    super.initState();

    onCheckBoxChangedNotifier = ValueNotifier<bool>(null)
    ..addListener(() {
      if (onCheckBoxChangedNotifier.value) {
        widget.playlist.add(widget.targetMusic).save();
      } else {
        widget.playlist.remove(widget.targetMusic).save();
      }
    });
  }

  @override
  void dispose () {
    onCheckBoxChangedNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAddedToPlaylist(widget.targetMusic),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
          case ConnectionState.none: {
            return Center(child: FlutterLogo());
            break;
          }
          case ConnectionState.done: {
            return Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: _FlatCheckBox(
                    snapshot.data,
                    onCheckBoxChangedNotifier: onCheckBoxChangedNotifier
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(widget.playlist.name)
                  )
                )
              ]
            );
            break;
          }
        }
      }
    );
  }

  Future<bool> _isAddedToPlaylist (Music targetMusic) async {
    return List.from(widget.playlist.musics.map((Music music) => music.id)).contains(targetMusic.id);
  }
}

//
class _FlatCheckBox extends StatefulWidget {
  final bool initCheckBox;
  final ValueNotifier<bool> onCheckBoxChangedNotifier;

  _FlatCheckBox (this.initCheckBox, {@required this.onCheckBoxChangedNotifier});

  @override
  _FlatCheckBoxState createState () {
    return _FlatCheckBoxState();
  }
}

class _FlatCheckBoxState extends State<_FlatCheckBox> {
  bool _checkBox;

  @override
  void initState () {
    super.initState();

    _checkBox = widget.initCheckBox;
  }
  
  @override
  Widget build (BuildContext context) {
    return Checkbox(
      onChanged: (bool tog) {
        setState(() {
          _checkBox = tog;
          widget.onCheckBoxChangedNotifier.value = tog;
        });
      },
      value: _checkBox
    );
  }
}