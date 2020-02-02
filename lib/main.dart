import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riot_quiche/Enumerates/RouteName.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/QuicheEntrance/main.dart';
import 'package:riot_quiche/QuicheInitialization/main.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/QuicheSplash/main.dart';

import 'package:riot_quiche/Settings.dart';


void main() => runApp(QuicheMusicPlayer());

class QuicheMusicPlayer extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nakamara has gone',
      routes: <String, WidgetBuilder>{
        RouteName.Splash.name: (BuildContext context) {
          return QuicheSplash(
            minDuration: Duration(seconds: 2),
            /**
             * TODO:
             * decide what we do here
             */
            someFuture: Future.delayed(Duration(microseconds: 500)),
          );
        },
        RouteName.Entrance.name: (BuildContext context) {
          /**
           * TODO:
           * this widget toggle [QuicheHome] and [QuicheInitialization]
           */
          return QuicheEntrance();
        },
        RouteName.Initialization.name: (BuildContext context) {
          return QuicheInitialization();
        },
        RouteName.Home.name: (BuildContext context) {
          return QuicheHome();
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }

}