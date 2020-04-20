

import 'package:flutter/material.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';

enum StackLayerType{
  SnowAnimation,
  Circle,
}

class StackLayerVariables{
  static List<LayerProp> getLayerPropList(StackLayerType type){
    switch (type){
      case StackLayerType.SnowAnimation:
        return SnowAnimation.getSettingList();
        break;
      case StackLayerType.Circle:
        return CircleMine.getSettingList();
        break;
    }
    return null;
  }

  static CustomizableWidget getAddLayer(StackLayerType type, List<LayerProp> list, Size screenSize){
    switch (type){
      case StackLayerType.SnowAnimation:
        return SnowAnimation.fromLayerPropList(list, screenSize);
        break;
      case StackLayerType.Circle:
        return CircleMine.fromLayerPropList(list, screenSize);
        break;
    }
    return null;
  }

}




//bool-ラジオボタン-, Stringも追加しないとかな
enum LayerPropType{
  number,
  color,
  boolean,
  string,
}

class LayerProp{
  LayerPropType _layerPropType;
  String _entry, _description;

  dynamic _result;// 初期値を必ず追加しておくことが必要である

  LayerProp({
    @required LayerPropType layerPropType,
    @required String entry,
    String description = null,
    dynamic initValue = null,
  }): this._layerPropType = layerPropType,
        this._entry = entry,
        this._description = description,
        this._result = initValue;

  LayerPropType get layerPropType => _layerPropType;
  String        get entry         => _entry;
  String        get description   => _description;
  dynamic       get result        => _result;

  void setResult(dynamic res){
    this._result = res;
  }
}