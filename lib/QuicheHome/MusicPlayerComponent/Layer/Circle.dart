import 'dart:ui';
import 'package:flutter/material.dart';


//translate で囲むような感じの項目も追加する。

class Circle extends StatelessWidget{
  double diameter, longSide, shortSide;
  double strokeWidth;
  double value;
  Color color;

  /// [diameter]は円の直径を、[longSide]、[shortSide]はそれぞれ円の長辺、短辺を表す。
  /// 直径よりも長短辺が優先され、どちらも入力されたときは長短辺がセットされる。また、
  /// 直径か長短辺のどちらかnullではいけない。
  /// [strokeWidth]は線幅を表す。
  /// [value]は円の表示する割合を表す。
  /// [color]は線の色を表す。

  Circle({
    this.diameter,
    this.longSide,
    this.shortSide,
    this.strokeWidth = 1.0,
    this.value,
    this.color = Colors.white,
  }) : assert(diameter != null || (longSide != null && shortSide != null)); // assertは,で繋ぐと複数出来る

  @override
  Widget build(BuildContext context) {
    if (diameter != null && (longSide == null && shortSide == null)){
      longSide = diameter;
      shortSide = diameter;
    }

    // TODO: rotateをここに含める.

    return Center(
      child: Container(
        height: longSide,
        width: shortSide,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          value: value,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }

}

