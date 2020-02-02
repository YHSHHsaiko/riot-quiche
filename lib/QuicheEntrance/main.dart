import 'package:flutter/material.dart';

import 'package:riot_quiche/Enumerates/RouteName.dart';
import 'package:riot_quiche/QuicheOracle.dart';


class QuicheEntrance extends StatefulWidget {

  @override
  _QuicheEntranceState createState () {
    return _QuicheEntranceState();
  }
}

class _QuicheEntranceState extends State<QuicheEntrance> {

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _decideRoad(context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Center(child: Text("loading..."));
      }
    );
  }

  Future<Null> _decideRoad (BuildContext context) async {
    bool isInitialized = await QuicheOracleFunctions.checkInitialization();

    if (isInitialized) {
      Navigator.of(context).pushReplacementNamed(RouteName.Home.name);
    } else {
      Navigator.of(context).pushReplacementNamed(RouteName.Initialization.name);
    }
  }
}