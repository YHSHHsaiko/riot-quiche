import 'package:flutter/material.dart';

import 'package:riot_quiche/Enumerates/RouteName.dart';


class QuicheSplash extends StatefulWidget {
  final Future someFuture;
  final Duration minDuration;
  
  const QuicheSplash ({
    @required this.someFuture,
    @required this.minDuration,
    Key key
  }): super(key: key);

  @override
  _QuicheSplashState createState () {
    return _QuicheSplashState();
  }
}

class _QuicheSplashState extends State<QuicheSplash> {
  bool _isFinished;

  @override
  void initState() {
    super.initState();

    _isFinished = false;
  }
  
  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _animateUntil(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          /**
          * TODO:
          * set a fixed time animation.
          */
          return Center(
            child: FlutterLogo()
          );
        },
      )
    );
  }

  Future<Null> _animateUntil (BuildContext context) async {
    Future.delayed(widget.minDuration).then((_) {
      if (_isFinished) {
        Navigator.of(context).pushReplacementNamed(RouteName.Entrance.name);
      } else {
        _isFinished = true;
      }
    });

    widget.someFuture.then((_) {
      if (_isFinished) {
        Navigator.of(context).pushReplacementNamed(RouteName.Entrance.name);
      } else {
        _isFinished = true;
      }
    });
  }
}