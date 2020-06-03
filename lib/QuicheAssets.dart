import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:path/path.dart' as p;


class QuicheAssets {

  static final _assetFolder = 'assets';

  // App Icon
  static String get iconPath => p.join(_assetFolder, 'images', 'icon.png');
  static Image get icon => Image.asset(iconPath);
  static Future<ByteData> get iconBytes async {
    return await rootBundle.load(iconPath);
  }
  
}