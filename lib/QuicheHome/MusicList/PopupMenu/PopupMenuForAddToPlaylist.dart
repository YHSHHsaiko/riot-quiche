import 'package:flutter/material.dart';

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
  List<String> _playlistNameList;
  ValueNotifier<String> onPlaylistInputValueNotifier;
  //

  @override
  void initState () {
    super.initState();

    onPlaylistInputValueNotifier = ValueNotifier<String>(null)
    ..addListener(() {
      setState(() {
        _playlistNameList.add(onPlaylistInputValueNotifier.value);
        QuicheOracleFunctions.addPlaylist(onPlaylistInputValueNotifier.value);
      });
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
              if (_playlistNameList == null) {
                return Center(child: FlutterLogo());
              } else {
                return Column(
                  children: <Widget>[
                    _PlaylistInput(
                      _playlistNameList,
                      onPlaylistInputValueNotifier: onPlaylistInputValueNotifier
                    ),
                    for (int i = 0; i < _playlistNameList.length; ++i) _PlaylistCell(
                      _playlistNameList[i],
                      widget.targetMusic
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
    _playlistNameList = await QuicheOracleVariables.playlistsName;
    if (_playlistNameList == null) {
      _playlistNameList = [];
    }
  }
}

//
class _PlaylistInput extends StatefulWidget {
  final List<String> playlistNameList;
  final ValueNotifier<String> onPlaylistInputValueNotifier;


  _PlaylistInput (this.playlistNameList, {@required this.onPlaylistInputValueNotifier});

  @override
  _PlaylistInputState createState () {
    return _PlaylistInputState();
  }
}

class _PlaylistInputState extends State<_PlaylistInput> {
  TextEditingController _textEditingController;
  Color _inputColor;
  String _addedPlaylistName;
  
  @override
  void initState () {
    super.initState();

    _textEditingController = TextEditingController();
    _inputColor = Colors.black;
  }

  @override
  Widget build (BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: FlatButton(
            onPressed: () {
              if (!widget.playlistNameList.contains(_addedPlaylistName)) {
                widget.onPlaylistInputValueNotifier.value = _addedPlaylistName;
              }
            },
            child: Icon(Icons.exposure_plus_1)
          )
        ),
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              labelStyle: TextStyle(color: _inputColor)
            ),
            controller: _textEditingController,
            onChanged: (String changedString) {
              _addedPlaylistName = changedString;
              if (widget.playlistNameList.contains(_addedPlaylistName)) {
                _inputColor = Colors.red;
              } else {
                _inputColor = Colors.blue;
              }
            }
          )
        )
      ]
    );
  }
}

//
class _PlaylistCell extends StatefulWidget {
  final String playlistName;
  final Music targetMusic;

  _PlaylistCell (this.playlistName, this.targetMusic);

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
        QuicheOracleFunctions.addToPlaylist(widget.playlistName, widget.targetMusic);
      } else {
        QuicheOracleFunctions.removeFromPlaylist(widget.playlistName, widget.targetMusic);
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
                  child: Text(widget.playlistName)
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
    List<Music> playlist = await QuicheOracleFunctions.getPlaylistFromName(widget.playlistName);
    return playlist.contains(targetMusic.id);
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