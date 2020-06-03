

import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/StackLayerType.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';


class StackLayerVariables{
  static List<LayerProp> getLayerPropList(StackLayerType type){
    switch (type){
      case StackLayerType.SnowAnimation:
        return SnowAnimation.getSettingList();
        break;
      case StackLayerType.CircleMine:
        return CircleMine.getSettingList();
        break;
      
      default:
        return null;
    }
  }

  static CustomizableWidget getAddLayer(StackLayerType type, List<LayerProp> list, Size screenSize){
    switch (type){
      case StackLayerType.SnowAnimation:
        return SnowAnimation.fromLayerPropList(list, screenSize);
        break;
      case StackLayerType.CircleMine:
        return CircleMine.fromLayerPropList(list, screenSize);
        break;
      
      default:
        return null;
    }
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
  bool _isSetting;
  int _index;

  dynamic _result;// 初期値を必ず追加しておくことが必要である

  LayerProp({
    @required LayerPropType layerPropType,
    @required String entry,
    String description = null,
    dynamic initValue = null,
    bool isSetting,
    int index,
  }): this._layerPropType = layerPropType,
        this._entry = entry,
        this._description = description,
        this._result = initValue,
        this._isSetting = isSetting,
        this._index = index;

  LayerPropType get layerPropType => _layerPropType;
  String        get entry         => _entry;
  String        get description   => _description;
  dynamic       get result        => _result;
  bool          get isSetting     => _isSetting;
  int           get index         => _index;

  void setResult(dynamic res){
    this._result = res;
  }
}