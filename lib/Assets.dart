import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;

class Assets {

  static final _assetFolder = 'assets';

  // App Icon
  static AssetImage get icon {
    return AssetImage(p.join(_assetFolder, 'images', 'icon.png'));
  }
}