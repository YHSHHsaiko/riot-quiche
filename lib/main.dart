import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:riot_quiche/Enumerates/RouteName.dart';
import 'package:riot_quiche/QuicheEntrance/main.dart';
import 'package:riot_quiche/QuicheHome/main.dart';
import 'package:riot_quiche/QuicheInitialization/main.dart';
import 'package:riot_quiche/QuicheSplash/main.dart';


void main() => runApp(QuicheMusicPlayer());

class QuicheMusicPlayer extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nakamara has gone',
      routes: <String, WidgetBuilder>{
        RouteName.Splash.name: (BuildContext context) {
          print('current Widget: ${RouteName.Splash.name}');
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
          print('current Widget: ${RouteName.Entrance.name}');

          /**
           * TODO:
           * this widget toggle [QuicheHome] and [QuicheInitialization]
           */
          return QuicheEntrance();
        },
        RouteName.Initialization.name: (BuildContext context) {
          print('current Widget: ${RouteName.Initialization.name}');
          
          return QuicheInitialization();
        },
        RouteName.Home.name: (BuildContext context) {
          print('current Widget: ${RouteName.Home.name}');

          return QuicheHome();
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }

}