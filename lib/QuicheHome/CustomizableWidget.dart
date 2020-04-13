import 'package:flutter/material.dart';

import 'package:riot_quiche/QuicheOracle.dart';


abstract class CustomizableWidget extends Widget {

  LayerType layerType;

  // =================== =
  // static methods
  // =================== =
  static Widget fromJson (String layerIdentifier, Map<String, dynamic> setting) {
    // =================== =
    // TODO:
    // jsonからlayerIdentifierインスタンスを作成
    // =================== =
    return Text("efgeff");
  }
  
  // return a serialized setting
  Map<String, dynamic> get setting;
  // set a widget's setting
  set setting (Map<String, dynamic> importedSetting);
}



enum LayerType {
  snowAnimation,
  circleMine,
}