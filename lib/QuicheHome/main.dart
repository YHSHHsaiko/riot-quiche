import 'package:flutter/material.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheOracle.dart';


class QuicheHome extends StatefulWidget {
  
  @override
  _QuicheHomeState createState () {
    return _QuicheHomeState();
  }
}

class _QuicheHomeState extends State<QuicheHome> {

  /**
   * TODO:
   * Music Playerrrrrrrrrrrrrrrrrrrrrrr
   */
  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _buildPlayer(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting: {
              return Center(child: Text('こんにちはー'));
              break;
            }
            case ConnectionState.done: {
              if (QuicheOracleVariables.mediaIdList == null) {
                return Center(child: Text('こんにちはー'));
              } else {
                /**
                 * TODO:
                 * main stack widget?
                 */
                return ListView.builder(
                  itemCount: QuicheOracleVariables.mediaIdList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FlatButton(
                      onPressed: () async {
                        await PlatformMethodInvoker.init(QuicheOracleVariables.mediaIdList[index]);
                        PlatformMethodInvoker.play();
                      },
                      child: Center(child: Text('こんにちはー： ${QuicheOracleVariables.mediaIdList[index]}'))
                    );
                  },
                );
              }
              
              break;
            }
            case ConnectionState.none: {
              return Center(child: Text('こんにちはー'));
              break;
            }
            case ConnectionState.active: {
              return Center(child: Text('こんにちはー'));
              break;
            }
            default: {
              return Center(child: Text('こんにちはー'));
              break;
            }
          }
        },
      )
    );
  }

  Future<dynamic> _buildPlayer () async {
    await PlatformMethodInvoker.trigger();
    List<String> mediaIdList = await PlatformMethodInvoker.butterflyEffect();
    QuicheOracleVariables.mediaIdList = mediaIdList;

    return null;
  }
}