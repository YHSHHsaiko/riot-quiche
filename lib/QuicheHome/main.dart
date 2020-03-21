import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/ExoPlayerPlaybackState.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayer.dart';
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
              return Center(child: Text('こんにちはーwait'));
              break;
            }
            case ConnectionState.done: {
              if (QuicheOracleVariables.musicList == null) {// || QuicheOracleVariables.musicList.length == 0
                return Center(child: Text('こんにちはーdone1'));
              } else {
                /**
                 * TODO:
                 * main stack widget?
                 * ここで呼び出されるから画面遷移の度に音楽が再生され直す。
                 */
<<<<<<< HEAD
                print('ここか？');
                return MusicPlayer("newplay", null);
=======
                return ListView.builder(
                  itemCount: QuicheOracleVariables.musicList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FlatButton(
                      onPressed: () async {
                        PlatformMethodInvoker.setCurrentMediaId(QuicheOracleVariables.musicList[index].id);
                        PlatformMethodInvoker.playFromCurrentMediaId();
                      },
                      child: Center(child: Text('こんにちはー： ${QuicheOracleVariables.musicList[index].title}'))
                    );
                  },
                );
>>>>>>> 6e443ae781bcc30d256f0b5aed9120e30f5cade5
              }
              
              break;
            }
            case ConnectionState.none: {
              return Center(child: Text('こんにちはーnone'));
              break;
            }
            case ConnectionState.active: {
              return Center(child: Text('こんにちはーactive'));
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

    void Function(int position, int state) onData = (int position, int state) {
        print('position: ${Duration(milliseconds: position).inSeconds}');
        print('state: ${ExoPlayerPlaybackStateExtension.of(state)}');
    };
    PlatformMethodInvoker.redShift(
      onData,
      onError: (dynamic) {
        print('ERROR!');
      },
      onDone: () {
        print('end of .:<RedShift>:-^');
      }
    );

    return null;
  }
}