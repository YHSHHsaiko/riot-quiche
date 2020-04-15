import 'package:flutter/cupertino.dart';
import 'package:riot_quiche/Music/Music.dart';


class Album extends Albatross{
//  final String _id;
//  String get id => _id;
//  final String _title;
//  String get title => _title;
  final String _artist;
  String get artist => _artist;

  Image _image;
  Image get image => _image;

  List<Music> _musics;
  List<Music> get musics => _musics;


  Album ({
    @required String id,
    @required String title,
    @required String artist,
    @required Image image,
    @required List<Music> musics,
  })
  : _artist = artist,
    _image = image,
    _musics = musics,
    super(id, title);

  void addMusic(Music value) {
    _musics.add(value);
  }

  Image getArt(){
    return _image;
  }
}