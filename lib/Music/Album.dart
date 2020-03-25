import 'package:flutter/cupertino.dart';


class Album {
  final String _id;
  String get id => _id;
  final String _title;
  String get title => _title;
  final String _artist;
  String get artist => _artist;
  final String _album;
  String get album => _album;
  final int _duration;
  int get duration => _duration;
  final String _artUri;
  String get artUri => _artUri;

  Album ({
    @required String id,
    @required String title,
    @required String artist,
    @required String album,
    @required int duration,
    @required String artUri
  })
  : _id = id,
    _title = title,
    _artist = artist,
    _album = album,
    _duration = duration,
    _artUri = artUri;
}