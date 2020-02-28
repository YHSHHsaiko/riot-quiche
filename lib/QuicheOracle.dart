import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;

import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Music.dart';


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

  // serialized widget's json file path
  static Future<Directory> get serializedJsonDirectory async {
    Directory localDirectory = await pp.getApplicationDocumentsDirectory();

    return Directory(p.absolute(localDirectory.path, "widgets"));
  }
}


extension QuicheOracleFunctions on QuicheOracle {
  // whether to app is initialized
  static Future<bool> checkInitialization () {
    /**
     * TODO:
     * check whether to app is initialized
     */
    
    return Future.value(false);
  }

  static List<Music> getSortedMusicList (SortType sortType) {
    /**
     * TODO:
     * return the sorted Music List according to sortType.
     */
    
    List<Music> sortedList;
    
    switch (sortType) {
      case SortType.TITLE_ASC: {
        break;
      }
      case SortType.ARTIST_ASC: {
        break;
      }
      case SortType.ALBUM_ASC: {
        break;
      }
      case SortType.TITLE_DESC: {
        break;
      }
      case SortType.ARTIST_DESC: {
        break;
      }
      case SortType.ALBUM_DESC: {
        break;
      }
    }
  }
}