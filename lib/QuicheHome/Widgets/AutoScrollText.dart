import 'dart:async';

import 'package:flutter/material.dart';

import 'package:riot_quiche/Enumerates/ScrollEnum.dart';


//長さが収まっちゃうときは、動かないような構造に
//現状呼び出す側でHeightで囲む必要性あり


class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  AutoScrollText({
    @required this.text,
    this.textStyle,
  }) : assert(text != null,);

  @override
  State<StatefulWidget> createState() => AutoScrollTextState();
}

class AutoScrollTextState extends State<AutoScrollText> with SingleTickerProviderStateMixin {
  ScrollController scrollController;
  Size screenSize;
  double position = 0.0;
  Timer timer;
  final double _moveDistance = 3.0;
  final int _timerRest = 100;
  GlobalKey _key = GlobalKey();
  final int tickNumber = 30;
//  double widgetWidth, widgetHeight;

  @override
  void initState() {
    super.initState();
//    widgetWidth  = _key.currentContext.findRenderObject().paintBounds.size.width;
//    widgetHeight = _key.currentContext.findRenderObject().paintBounds.size.height;
//    print(widgetHeight);
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      startTimer();
    });
  }

  int tickerBase = 0;
  ScrollEnum moving = ScrollEnum.before;

  void startTimer() {

    if (_key.currentContext != null) {

      timer = Timer.periodic(Duration(milliseconds: _timerRest), (Timer timer)  async {
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        double pixels = scrollController.position.pixels;

        switch (moving){
          case ScrollEnum.before:
            if (timer.tick - tickerBase > tickNumber){
              moving = ScrollEnum.now;
            }
            break;
          case ScrollEnum.now:
            position += _moveDistance;
            scrollController.animateTo(
              position,
              duration: Duration(milliseconds: _timerRest),
              curve: Curves.linear,
            );
            if (pixels + 2*_moveDistance >= maxScrollExtent) {
              moving = ScrollEnum.after;
              tickerBase = timer.tick;
            }
            break;
          case ScrollEnum.after:
            if (timer.tick - tickerBase > tickNumber){
              position = 0.0;
              scrollController.jumpTo(position);
              moving = ScrollEnum.before;
              tickerBase = timer.tick;
            }
            break;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  Widget getText() {
    return Center(
      child: Text(
        widget.text,
        style: widget.textStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    print(widgetHeight);
    return ListView(
      shrinkWrap: true,
      key: _key,
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        getText(),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }
}