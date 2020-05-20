import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Playlist {
  final String _name;
  String get name => _name;

  final List<Music> _musics;
  List<Music> get musics => _musics;

  final Map<String, Music> _musicMap;
  Map<String, Music> get musicMap => Map<String, Music>.from(_musicMap);

  static const prefName = 'playlists';

  // constructor //////////////////////////////////
  Playlist (this._name, this._musics)
  : _musicMap = Map<String, Music>.fromEntries(_musics.map((Music music) => MapEntry<String, Music>(music.id, music)));


  static Future<Playlist> fromName (String playlistName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('${prefName}::${playlistName}')) {
      List<String> ids = prefs.getStringList('${prefName}::${playlistName}');
      List<Music> musics = [];

      for (String id in ids) {
        if (QuicheOracleVariables.musicMap.containsKey(id)) {
          musics.add(QuicheOracleVariables.musicMap[id]);
        }
      }

      return Playlist(playlistName, musics);

    } else {
      return null;
    }
  }
  //             //////////////////////////////////

  // methods //////////////////////////////////////
  Playlist add (Music target) {
    _musicMap[target.id] = target;
    _musics.add(target);

    return this;
  }


  Playlist remove (Music target) {
    _musicMap.remove(target.id);
    _musics.remove(target);

    return this;
  }

  Future<Playlist> save () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(prefName)) {
      List<String> playlistNames = prefs.getStringList(prefName);

      if (!playlistNames.contains(name)) {
        prefs.setStringList(prefName, playlistNames);
      }
    } else {
      prefs.setStringList(prefName, <String>[name]);
    }

    prefs.setStringList(
      '${prefName}::${_name}',
      List<String>.from(_musicMap.keys)
    );

    return this;
  }
  //        //////////////////////////////////////

  // static methods //////////////////////////////
  static Future<List<Playlist>> get playlists async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey(prefName)) {
      List<Playlist> result = [];
      for (String playlistName in prefs.getStringList(prefName)) {
        result.add(await Playlist.fromName(playlistName));
      }

      return result;
    } else {
      return [];
    }
  }
  //                //////////////////////////////

}