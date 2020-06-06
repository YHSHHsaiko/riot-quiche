import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:riot_quiche/Enumerates/RouteName.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheEntrance/main.dart';
import 'package:riot_quiche/QuicheHome/main.dart';
import 'package:riot_quiche/QuicheInitialization/main.dart';
import 'package:riot_quiche/QuicheSplash/main.dart';


void main() => runApp(QuicheMusicPlayer());

class QuicheMusicPlayer extends StatelessWidget with WidgetsBindingObserver {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'phonier',
      routes: <String, WidgetBuilder>{
        RouteName.Splash.name: (BuildContext context) {
          print('current Widget: ${RouteName.Splash.name}');
          return QuicheSplash(
            minDuration: Duration(microseconds: 100),
            /**
             * TODO:
             * decide what we do here
             */
            someFuture: Future.delayed(Duration(microseconds: 100)),
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
          
          return const QuicheHome();
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState (AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached: {
        print(AppLifecycleState.detached);
        break;
      }
      default: {
        break;
      }
    }
  }

}