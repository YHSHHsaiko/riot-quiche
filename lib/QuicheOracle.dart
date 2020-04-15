import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;

import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Albatross.dart';
import 'package:riot_quiche/Music/Album.dart';
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

  // media ALBUM_ID List
  static List<String> albumIdList;


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

  static List<dynamic> getSortedMusicList (SortType sortType) {
    /**
     * TODO:
     * return the sorted Music List according to sortType.
     */
    
    List<dynamic> sortedList;
    
    switch (sortType) {
      case SortType.TITLE_ASC: {
        sortedList = QuicheOracleVariables.musicList;
        sortedList.sort((a,b) => a.title.compareTo(b.title) as int);
        break;
      }
      case SortType.ARTIST_ASC: {
        //TODO:
        sortedList = QuicheOracleVariables.musicList;
        break;
      }
      case SortType.ALBUM_ASC: {
        sortedList = _sortAlbum('ASC');
        break;
      }
      case SortType.TITLE_DESC: {
        sortedList = QuicheOracleVariables.musicList;
        sortedList.sort((a,b) => b.title.compareTo(a.title) as int);
        break;
      }
      case SortType.ARTIST_DESC: {
        //TODO:
        sortedList = QuicheOracleVariables.musicList;
        break;
      }
      case SortType.ALBUM_DESC: {
        sortedList = _sortAlbum('DESC');
        break;
      }
    }

    return sortedList;
  }

  static List<dynamic> _sortAlbum(String set){
    
    // assertion
    List<String> sortTypeList = ['ASC', 'DESC'];
    assert(sortTypeList.contains(set));

    // collect members of albums
    Map<String, List<Music>> albumList = Map<String, List<Music>>();
    for (Music music in QuicheOracleVariables.musicList) {
      String albumId = music.albumId;
      
      if (!albumList.containsKey(albumId)) {
        albumList[albumId] = List<Music>();
      }
      albumList[albumId].add(music);
    }

    // correct the order of members of albums
    List<Album> result = List<Album>();
    for (String albumId in albumList.keys) {
      albumList[albumId].sort((m1, m2) {
        int m1Id = int.parse(m1.id);
        int m2Id = int.parse(m2.id);
        return (set == 'ASC') ? m1Id.compareTo(m2Id) : m2Id.compareTo(m1Id);
      });

      Music target = albumList[albumId][0];
      result.add(Album(
        id: target.album,
        albumId: albumId,
        title: target.album,
        artist: target.artist,
        image: target.getArt(),
        musics: albumList[albumId]
      ));
    }

    return result;
  }
}