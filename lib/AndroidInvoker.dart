import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';


class AndroidInvoker {
  static const MethodChannel _methodChannel = const MethodChannel(
    'test_channel'
  );

  static Future<Null> hello () async {
    await _methodChannel.invokeMethod('hello', <dynamic>[]);
  }

  static Future<Null> coldSleep (int delay) async {
    await _methodChannel.invokeListMethod('coldSleep', <dynamic>[delay]);
  }

}
