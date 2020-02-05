import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;

import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/Music.dart';


abstract class QuicheOracle {
}


extension QuicheOracleVariables on QuicheOracle {
  // entire screen width
  static double screenWidth;
  // entire screen height
  static double screenHeight;

  // media ID List
  static List<Music> musicList;


  // permission information
  static final Map<Permission, bool> permissionInformation = Map<Permission, bool>.fromIterable(
    Permission.values,
    key: (key) => key as Permission,
    value: (_) => false,
  );
}


extension QuicheOracleFunctions on QuicheOracle {
  // serialized widget's json file path
  static Future<Directory> get serializedJsonDirectory async {
    Directory localDirectory = await pp.getApplicationDocumentsDirectory();

    return Directory(p.absolute(localDirectory.path, "widgets"));
  }

  // whether to app is initialized
  static Future<bool> checkInitialization () {
    /**
     * TODO:
     * check whether to app is initialized
     */
    
    return Future.value(false);
  }
}