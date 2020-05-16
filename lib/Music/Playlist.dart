import 'package:riot_quiche/Music/Music.dart';


class Playlist {
  final String _title;
  String get title => _title;
  
  final List<Music> _musics;
  List<Music> get musics => _musics;

  Playlist (this._title, this._musics);

  
}