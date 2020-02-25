import 'package:flutter/material.dart';
import 'package:riot_quiche/Music/Music.dart';
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
              if (QuicheOracleVariables.musicList == null) {
                return Center(child: Text('こんにちはー'));
              } else {
                /**
                 * TODO:
                 * main stack widget?
                 */
                return ListView.builder(
                  itemCount: QuicheOracleVariables.musicList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FlatButton(
                      onPressed: () async {
                        PlatformMethodInvoker.setCurrentMediaId(QuicheOracleVariables.musicList[index].id);
                        PlatformMethodInvoker.play();
                      },
                      child: Center(child: Text('こんにちはー： ${QuicheOracleVariables.musicList[index].title}'))
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
    List<Music> musicList = await PlatformMethodInvoker.butterflyEffect();
    QuicheOracleVariables.musicList = musicList;
    await PlatformMethodInvoker.setQueue(List<String>.from(QuicheOracleVariables.musicList.map((music) {
      return music.id;
    })));

    return null;
  }
}