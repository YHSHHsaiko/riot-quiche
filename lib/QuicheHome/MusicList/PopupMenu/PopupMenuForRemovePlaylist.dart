import 'package:flutter/material.dart';
import 'package:riot_quiche/Music/Album.dart';
import 'package:riot_quiche/Music/Playlist.dart';

import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PopupMenuForRemovePlaylist extends StatefulWidget {
  final Playlist targetPlaylist;

  PopupMenuForRemovePlaylist (this.targetPlaylist);

  @override
  _PopupMenuForRemovePlaylistState createState () {
    return _PopupMenuForRemovePlaylistState();
  }
}

class _PopupMenuForRemovePlaylistState extends State<PopupMenuForRemovePlaylist> {

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            flex:3,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('プレイリスト <${widget.targetPlaylist.name}> を削除しますか？')
              )
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')
              ),
              FlatButton(
                onPressed: () async {
                  await Playlist.removePlaylist(widget.targetPlaylist);
                  Navigator.of(context).pop();
                },
                child: const Text('OK')
              )
            ]
          )
        ]
      )
    );
  }

}