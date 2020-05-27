import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;

class QuicheAssets {

  static final _assetFolder = 'assets';

  // App Icon
  static String get iconPath => p.join(_assetFolder, 'images', 'icon.png');

  static Image get icon {
    return Image.asset(iconPath);
  }
}