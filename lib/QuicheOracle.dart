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

  // media ARTIST_ID List
  static List<String> artistIdList;


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
        sortedList.sort((a,b) => a.title.compareTo(b.title));
        break;
      }
      case SortType.ARTIST_ASC: {
        //TODO:
        sortedList = _sortFromIDType('artist', order: 'ASC');
        break;
      }
      case SortType.ALBUM_ASC: {
        sortedList = _sortFromIDType('album', order: 'ASC');
        break;
      }
      case SortType.TITLE_DESC: {
        sortedList = QuicheOracleVariables.musicList;
        sortedList.sort((a,b) => b.title.compareTo(a.title));
        break;
      }
      case SortType.ARTIST_DESC: {
        //TODO:
        sortedList = _sortFromIDType('artist', order: 'DESC');
        break;
      }
      case SortType.ALBUM_DESC: {
        sortedList = _sortFromIDType('album', order: 'DESC');
        break;
      }
    }

    return sortedList;
  }

  static List<Album> _sortFromIDType (
    String idType,
    {String order = 'ASC'}) {
    
    // assertion
    List<String> orderList = ['ASC', 'DESC'];
    List<String> idTypeList = ['album', 'artist'];
    assert(orderList.contains(order));
    assert(idTypeList.contains(idType));


    // collect members of albums
    Map<String, List<Music>> idList = Map<String, List<Music>>();
    for (Music music in QuicheOracleVariables.musicList) {
      String id;
      switch (idType) {
        case 'album': {
          id = music.albumId;
          break;
        }
        case 'artist': {
          id = music.artistId;
          break;
        }
      }
      
      if (!idList.containsKey(id)) {
        idList[id] = List<Music>();
      }
      idList[id].add(music);
    }

    // correct the order of members of albums
    List<Album> result = List<Album>();
    for (String id in (order == 'ASC') ? idList.keys : List<String>.from(idList.keys).reversed) {
      idList[id].sort((m1, m2) {
        int m1Id = int.parse(m1.id);
        int m2Id = int.parse(m2.id);
        return m1Id.compareTo(m2Id);
      });

      Music target = idList[id][0];

      switch (idType) {
        case 'album': {
          result.add(Album(
            id: target.albumId,
            albumId: id,
            artistId: target.artistId,
            title: target.album,
            artist: target.artist,
            image: target.getArt(),
            musics: idList[id]
          ));
          break;
        }
        case 'artist': {
          result.add(Album(
            id: target.albumId,
            albumId: id,
            artistId: target.artistId,
            title: target.artist,
            artist: target.artist,
            image: target.getArt(),
            musics: idList[id]
          ));
          break;
        }
      }
    }

    return result;
  }
}