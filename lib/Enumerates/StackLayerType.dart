import 'package:flutter/cupertino.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';
import 'package:riot_quiche/QuicheOracle.dart';

enum StackLayerType {
  SnowAnimation,
  Circle,
}


extension LayerTypeExt on StackLayerType {
  CustomizableWidget ofDefault () {
    CustomizableWidget result;

    switch (this) {
      case StackLayerType.Circle: {
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
    }

    return result;
  }
}