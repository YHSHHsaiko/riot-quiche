import 'package:flutter/material.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';

import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Enumerates/StackLayerType.dart';


abstract class CustomizableWidget {
  final StackLayerType layerType = StackLayerType.None;
  final String uniqueID = '';
  

  CustomizableWidget importSetting (Map<String, dynamic> importedSetting);
  Map<String, dynamic> exportSetting ();

  String get imagePath;
  String get widgetNameJP;

  //
  static CustomizableWidget fromJson (Map<String, dynamic> layerJson) {
    CustomizableWidget result;

    switch (StackLayerTypeExt.fromName(layerJson['stackLayerType'])) {

      case StackLayerType.SnowAnimation:
        result = SnowAnimation.fromJson(layerJson);
        break;
      case StackLayerType.CircleMine:
        result = CircleMine.fromJson(layerJson);
        break;
      case StackLayerType.None:
        result = null;
        break;
      default:
        throw Exception('not implemented CustomizableWidget.fromJson()::${StackLayerTypeExt.fromName(layerJson['stackLayerType'])}');
    }

    return result;
  }
}


abstract class CustomizableStatefulWidget extends StatefulWidget implements CustomizableWidget {

  CustomizableStatefulWidget (
    {
      Key key,
    }
  )
  : super(key: key);
}


abstract class CustomizableStatelessWidget extends StatelessWidget implements CustomizableWidget {

  final StackLayerType layerType = StackLayerType.None;

  CustomizableStatelessWidget (
    {
      Key key,
    }
  )
  : super(key: key);
}