import 'package:flutter/material.dart';

import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Enumerates/LayerType.dart';


abstract class CustomizableWidget {
  final LayerType layerType = LayerType.NONE;
  final uniqueID = '';

  CustomizableWidget (
    {
      Key key
    }
  );

  CustomizableWidget importSetting (Map<String, dynamic> importedSetting);
  void exportSetting ();

  String get imagePath;
  String get widgetNameJP;
}


abstract class CustomizableStatefulWidget extends StatefulWidget implements CustomizableWidget {

  CustomizableStatefulWidget (
    {
      Key key
    }
  )
  : super(key: key);

  CustomizableStatefulWidget.fromJson (
    Map<String, dynamic> importedSetting,
    {
      Key key
    }
  )
  : super(key: key);
}


abstract class CustomizableStatelessWidget extends StatelessWidget implements CustomizableWidget {

  final LayerType layerType = LayerType.NONE;

  CustomizableStatelessWidget (
    {
      Key key
    }
  )
  : super(key: key);

  CustomizableStatelessWidget.fromJson (
    Map<String, dynamic> importedSetting,
    {
      Key key
    }
  )
  : super(key: key);
}