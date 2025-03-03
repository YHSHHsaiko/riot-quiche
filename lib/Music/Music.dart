import 'package:flutter/material.dart';

import 'dart:io';


class Music {
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
  final String _path;
  String get path => _path;

  
  Music ({
    @required String id,
    @required String title,
    @required String artist,
    @required String album,
    @required int duration,
    @required String artUri,
    @required String path
  })
  : _id = id,
    _title = title,
    _artist = artist,
    _album = album,
    _duration = duration,
    _artUri = artUri,
    _path = path;


  String chooseArtUri ({String format = 'png'}) {
    String result;

    if (_artUri != null) {
      result = _artUri;
    } else {
      List<String> splitedPath = path.split('/');
      String rawPath = splitedPath.sublist(0, splitedPath.length - 1).join('/');

      // ジャケットの名前はアルバム名かな？
      String jacketPath = [rawPath, album + '.$format'].join('/');

      if (File(jacketPath).existsSync()) {
        result = jacketPath;
      } else {
        // ジャケットの名前は曲名かな？
        jacketPath = [rawPath, title + '.$format'].join('/');
        if (File(jacketPath).existsSync()) {
          print(jacketPath);
          result = jacketPath;
        } else {
          // じゃあファイル名かな？
          List<String> tmpSplited = path.split('.');
          jacketPath = tmpSplited.sublist(0, tmpSplited.length - 1).join('/') + '.$format';
          if (File(jacketPath).existsSync()) {
            result = jacketPath;
          } else {
            // これでだめならもうねえだろ
            result = null;
          }
        }
      }
    }

    return result;
  }
}