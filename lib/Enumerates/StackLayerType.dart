import 'package:flutter/cupertino.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';
import 'package:riot_quiche/QuicheOracle.dart';


enum StackLayerType {
  SnowAnimation,
  CircleMine,
  None
}

extension StackLayerTypeExt on StackLayerType {
  static final Map<StackLayerType, String> _nameMap = Map.fromEntries(
    StackLayerType.values.map(
      (e) => MapEntry<StackLayerType, String>(e, e.toString().split('.')[1])
    )
  );

  static StackLayerType fromName (String layerTypeName) {
    for (StackLayerType layerType in StackLayerType.values) {
      if (layerType.name == layerTypeName) {
        return layerType;
      }
    }

    return null;
  }

  String get name => _nameMap[this];

  CustomizableWidget ofDefault () {
    CustomizableWidget result;

    switch (this) {
      case StackLayerType.CircleMine: {
        result = CircleMine(
          screenSize: Size(
            QuicheOracleVariables.screenWidth,
            QuicheOracleVariables.screenHeight
          )
        );
        break;
      }
      case StackLayerType.SnowAnimation: {
        result = SnowAnimation(
          screenSize: Size(
            QuicheOracleVariables.screenWidth,
            QuicheOracleVariables.screenHeight
          )
        );
        break;
      }

      case StackLayerType.None: {
        result = null;
        break;
      }
    }

    return result;
  }

}