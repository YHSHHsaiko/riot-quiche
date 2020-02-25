import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/Music/Music.dart';


class PlatformMethodInvoker {
  static const MethodChannel _methodChannel = const MethodChannel(
    'test_channel'
  );
  static const EventChannel _eventChannel = const EventChannel(
      'event_channel'
  );

  static Future<List<bool>> requestPermissions (List<Permission> permissions) async {
    List<int> arguments = permissions.map((element) {
      return Permission.values.indexOf(element);
    }).toList();
    var stream = _eventChannel.receiveBroadcastStream(<dynamic>[
      "requestPermissions", ...arguments
    ]).map<List<bool>>((res) {
      return (res as List<int>).map((element) {
        return element == 1;
      }).toList();
    });

    List<bool> res = await stream.first;
    return res;
  }

  static Future<bool> trigger () async {
    bool res = await _methodChannel.invokeMethod('trigger', <dynamic>[]);
    return res;
  }

  static Future<List<Music>> butterflyEffect () async {
    List<dynamic> butterfly = await _methodChannel.invokeMethod('butterflyEffect', <dynamic>[]);

    List<Music> musicList = List<Music>();
    for (List<dynamic> musicObject in butterfly) {
      String id = musicObject[0] as String;
      String title = musicObject[1] as String;
      String artist = musicObject[2] as String;
      String album = musicObject[3] as String;
      int duration = musicObject[4] as int;
      String artUri = musicObject[5] as String;

      Music music = Music(
        id: id,
        title: title,
        artist: artist,
        album: album,
        duration: duration,
        artUri: artUri
      );
      musicList.add(music);
    }
    return musicList;
  }

  static Future<Null> setQueue (List<String> mediaIdList) async {
    await _methodChannel.invokeMethod('setQueue', mediaIdList);
  }

  static Future<Null> setCurrentMediaId (String mediaId) async {
    await _methodChannel.invokeMethod('setCurrentMediaId', <dynamic>[mediaId]);
  }

  static Future<Null> play () async {
    await _methodChannel.invokeMethod('play', <dynamic>[]);
  }

}
