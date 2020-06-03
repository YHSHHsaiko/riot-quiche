import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayer.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:shared_preferences/shared_preferences.dart';


class QuicheHome extends StatefulWidget {
  const QuicheHome();
  
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
        builder: (BuildContext context, AsyncSnapshot snapshot1) {
          switch (snapshot1.connectionState) {
            case ConnectionState.waiting: {
              return Center(child: FlutterLogo());
              break;
            }
            case ConnectionState.done: {
              if (QuicheOracleVariables.musicList == null || QuicheOracleVariables.musicList.isEmpty) {
                return Center(
                  child: const Text('''
                  この端末にはまだ音楽が無いようです．
                  アプリを終了して，音楽を追加してください．
                  ''')
                );
              }

              if (!snapshot1.hasError) {
                if (QuicheOracleVariables.musicList == null) {
                  return Center(child: Text('こんにちはーdone1'));
                } else {
                  /**
                   * TODO:
                   * main stack widget?
                   * ここで呼び出されるから画面遷移の度に音楽が再生され直す。
                   */
                  Size screenSize = MediaQuery.of(context).size;
                  return FutureBuilder(
                    future: _initializeMusic(),
                    builder: (BuildContext context, AsyncSnapshot snapshot2) {
                      if (snapshot2.connectionState != ConnectionState.done) {
                        return Center(child: FlutterLogo());
                      }

                      List<dynamic> musicList = snapshot2.data[0];
                      int index = snapshot2.data[1];
                      int repeatChecker = snapshot2.data[2];
                      List<CustomizableWidget> layers = snapshot2.data[3];
                      return MusicPlayer(screenSize, musicList, index, repeatChecker, layers);
                    }
                  );
                }
              } else {
                return Center(
                  child: Text(
                    '<ERROR?>: Failed to initialization of Music Player.\n${snapshot1.data}'
                  ),
                );
              }
              
              break;
            }
            case ConnectionState.none: {
              return Center(child: FlutterLogo());
              break;
            }
            case ConnectionState.active: {
              return Center(child: FlutterLogo());
              break;
            }
            default: {
              return Center(child: FlutterLogo());
              break;
            }
          }
        },
      )
    );
  }

  Future<bool> _buildPlayer () async {
    bool isServiceAlreadyStarted = false;
    print('TRIGGER: START');

    try {
      isServiceAlreadyStarted = await PlatformMethodInvoker.trigger();
      print('RESULT OF TRIGGER: ${isServiceAlreadyStarted}');

      await PlatformMethodInvoker.butterflyEffect();

    } catch (err) {
      print(err);
    }

    return isServiceAlreadyStarted;
  }

  Future<dynamic> _initializeMusic () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> result;

    print('''
    prefs.containsKey(QuicheOracleVariables.musicCachePrefName):
    ${prefs.containsKey(QuicheOracleVariables.musicCachePrefName)}''');

    if (prefs.containsKey(QuicheOracleVariables.musicCachePrefName)) {
      String musicId = prefs.getString(QuicheOracleVariables.musicIdCachePrefName);
      List<String> queue = prefs.getStringList(QuicheOracleVariables.musicQueueCachePrefName);
      int repeatChecker = prefs.getInt(QuicheOracleVariables.musicRepeatCheckerPrefName);

      List<Music> musicList = List<Music>();
      for (String id in queue) {
        if (QuicheOracleVariables.musicMap.containsKey(id)) {
          musicList.add(QuicheOracleVariables.musicMap[id]);
        }
      }
    
      if (queue.contains(musicId)) {
        result = <dynamic>[musicList, queue.indexOf(musicId), repeatChecker];
      } else if (musicList.isNotEmpty) {
        result = <dynamic>[musicList, 0, repeatChecker];
      } else {
        result = <dynamic>[QuicheOracleVariables.musicList, 0, repeatChecker];
      }

    } else {
      result = <dynamic>[[QuicheOracleVariables.musicList[0]], 0, 1];
    }

    // load layer information
    await QuicheOracleFunctions.initializeDirectoryStructure();

    List<CustomizableWidget> layers = <CustomizableWidget>[];
    if (prefs.containsKey(QuicheOracleVariables.layerPresetIDPrefName)) {
      String presetIdentifier = prefs.getString(QuicheOracleVariables.layerPresetIDPrefName);
      File layersJsonFile = await QuicheOracleFunctions.getJsonLayerInformation(presetIdentifier);

      if (layersJsonFile.existsSync()) {
        List<Map<String, dynamic>> layersJsonList = List<Map<String, dynamic>>.from(
          QuicheOracleFunctions.loadJson(layersJsonFile)['layers']
        );

        for (Map<String, dynamic> layerJson in layersJsonList) {
          layers.add(CustomizableWidget.fromJson(layerJson));
        }
      }
    }
    result.add(layers);

    return result;
  }
}