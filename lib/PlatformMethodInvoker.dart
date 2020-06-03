import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/Enumerates/PlaybackState.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheOracle.dart';


class PlatformMethodInvoker {
  static const MethodChannel _methodChannel = const MethodChannel(
    'test_channel'
  );
  static const EventChannel _eventChannel = const EventChannel(
    'event_channel'
  );
  static const EventChannel _redShiftChannel = const EventChannel(
    'redshift_channel'
  );

  static String currentMediaId;
  static int currentQueueIndex;

  static Future<List<bool>> requestPermissions (List<Permission> permissions) async {
    print(permissions);
    List<int> arguments = permissions.map((element) {
      return Permission.values.indexOf(element);
    }).toList();
    Stream<List<bool>> stream = _eventChannel.receiveBroadcastStream(<dynamic>[
      'requestPermissions', ...arguments
    ]).map<List<bool>>((res) {
      print('permission results: $res');
      return List<int>.from(res).map((element) {
        return element == 1;
      }).toList();
    });

    List<bool> res = await stream.first;
    stream = null;
    return res;
  }

  static Future<bool> trigger () async {
    var stream = _eventChannel.receiveBroadcastStream(<dynamic>[
      'trigger'
    ]).map<bool>((res) {
      return (res as bool);
    });

    bool res = await stream.first;
    stream = null;
    if (res) {
      print('start service: riot-quiche');
    } else {
      throw Exception('start service failed.');
    }

    return res;
  }

  static Future<dynamic> butterflyEffect () async {
    List<dynamic> butterfly = await _methodChannel.invokeMethod('butterflyEffect', <dynamic>[]);

    QuicheOracleVariables.musicMap = Map<String, Music>();
    QuicheOracleVariables.musicList = List<Music>();
    QuicheOracleVariables.albumIdList = List<String>();
    QuicheOracleVariables.artistIdList = List<String>();

    for (List<dynamic> musicObject in butterfly) {
      String id = musicObject[0] as String;
      String albumId = musicObject[1] as String;
      String artistId = musicObject[2] as String;
      String title = musicObject[3] as String;
      String artist = musicObject[4] as String;
      String album = musicObject[5] as String;
      int duration = musicObject[6] as int;
      String artUri = musicObject[7] as String;
      String path = musicObject[8] as String;
      List<int> art = musicObject[9] as List<int>;

      Music music = Music(
        id: id,
        albumId: albumId,
        artistId: artistId,
        title: title,
        artist: artist,
        album: album,
        duration: duration,
        artUri: artUri,
        path: path,
        art: art
      );

      QuicheOracleVariables.musicMap[id] = music;
      QuicheOracleVariables.albumIdList.add(albumId);
      QuicheOracleVariables.artistIdList.add(artistId);
      QuicheOracleVariables.musicList.add(music);
    }
  }

  static Future<Null> setQueue (List<String> mediaIdList) async {
    await _methodChannel.invokeMethod('setQueue', mediaIdList);
  }

  static Future<Null> setCurrentMediaId (String mediaId) async {
    currentMediaId = mediaId;
    await _methodChannel.invokeMethod('setCurrentMediaId', <dynamic>[mediaId]);
  }

  static Future<Null> setCurrentQueueIndex (int index) async {
    currentQueueIndex = index;
    await _methodChannel.invokeMethod('setCurrentQueueIndex', <dynamic>[index]);
  }

  static Future<Null> playFromCurrentMediaId ({bool isForce = true}) async {
    await _methodChannel.invokeMethod('playFromCurrentMediaId', <dynamic>[isForce]);
  }

  static Future<Null> playFromCurrentQueueIndex ({bool isForce = true}) async {
    await _methodChannel.invokeMethod('playFromCurrentQueueIndex', <dynamic>[isForce]);
  }

  @deprecated
  static Future<Null> play () async {
    await _methodChannel.invokeMethod('play', <dynamic>[]);
  }
  
  static Future<Null> pause () async {
    await _methodChannel.invokeMethod('pause', <dynamic>[]);
  }

  static Future<Null> seekTo (int position) async {
    await _methodChannel.invokeMethod('seekTo', <dynamic>[position]);
  }

  static Stream<dynamic> redShift (
    void Function(int position, PlaybackState state) onData,
    {void Function(dynamic) onError, void Function() onDone}) {

    var stream = _redShiftChannel.receiveBroadcastStream(<dynamic>[
      'redShift'
    ]);

    final void Function(dynamic) _onData = (dynamic playbackInformationObject) {
      if (playbackInformationObject != null) {
        List<dynamic> playbackinformationList = playbackInformationObject as List<dynamic>;
        int position = playbackinformationList[0] as int;
        int state = playbackinformationList[1] as int;

        onData(position, PlaybackStateExt.of(state));
      } else {
        print('info: play back state is null.');
      }
    };

    return stream..listen(
      _onData,
      onError: onError,
      onDone: onDone
    );
  }

  static Future<Null> blueShift () async {
    print('<blueShift>: end of redShift.');
    await _methodChannel.invokeMethod('blueShift', <dynamic>[]);
  }

  /**
   * NOTE:
   * This two methods are omitted because of existance for [setCurrentQueueIndex] method.
   */
  // static Future<Null> skipToNext () async {
  //   await _methodChannel.invokeMethod('skipToNext', <dynamic>[]);
  // }

  // static Future<Null> skipToPrevious () async {
  //   await _methodChannel.invokeMethod('skipToPrevious', <dynamic>[]);
  // }

}
