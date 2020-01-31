import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';


class AndroidInvoker {
  static const MethodChannel _methodChannel = const MethodChannel(
    'test_channel'
  );

  static Future<bool> requestPermissions () async {
    bool res = await _methodChannel.invokeMethod('requestPermissions', <dynamic>[]);

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
