import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;

import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/Enumerates/SortType.dart';
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
        sortedList = sortAlbum('ASC');
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
        sortedList = sortAlbum('DESC');
        break;
      }
    }

    return sortedList;
  }
}






List<dynamic> sortAlbum(String set){
  List<Albatross> defaultList = QuicheOracleVariables.musicList;
  List<Albatross> albumList = [];
  List<Albatross> musicList = [];

  for (Music _music in defaultList){
    var key = _music.album;
    if (key == null){
      musicList.add(_music);
    }else{
      bool newAlbumFlag = true;

      for (Album _album in albumList){
        if (_album.title == _music.album){
          newAlbumFlag = false;
          _album.addMusic(_music);
        }
      }

      if (newAlbumFlag){
        albumList.add(Album(
          id: 'id',
          title: _music.album,
          artist: _music.artist,
          image: _music.getArt(),
          musics: [_music],
        ));
      }
    }
  }

  if (set == 'ASC'){
    albumList.addAll(musicList);
    return albumList;
  }else if (set == 'DESC'){
    musicList.addAll(albumList);
    return musicList;
  }
}





