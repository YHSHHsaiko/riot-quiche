import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:riot_quiche/Enumerates/Permission.dart';


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

  static Future<List<String>> butterflyEffect () async {
    List<dynamic> res = await _methodChannel.invokeMethod('butterflyEffect', <dynamic>[]);

    return List<String>.from(res);
  }

  static Future<Null> init (String mediaId) async {
    await _methodChannel.invokeMethod('init', <dynamic>[mediaId]);
  }

  static Future<Null> play () async {
    await _methodChannel.invokeMethod('play', <dynamic>[]);
  }

}
