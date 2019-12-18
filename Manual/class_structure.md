[☆]マークは分からないところ

# クラス構造
## 各Widgetの実装方法
### 命名規則
* ロジックの部分: ``Logic_****.dart``
* 描画処理の部分: ``****Widget.dart``

### フォルダの階層
* なんとかWidget[Folder]
  * Widget[Folder]
    * ``なんとかWidget.dart``
    * ``サブWidget.dart``(ロジックと分ける必要があるときは，サブフォルダに記述)
  * Logic[Folder]
    * ``Logic_なんとか.dart``

# デザインのたたき台
## メイン
![たたき台1](image/tataki_1.jpg)
## リスト
まだなし

# Function
## フォルダ探索
* 全探索
* フォルダ指定探索
アーティスト名などのメタデータを取得する必要がある．
https://developer.android.com/reference/android/media/MediaMetadataRetriever
を使うのかな？
Dart側でディレクトリ走査->Java側のMedaData取得ルーチンをコール?
```dart
static dynamic getMetaData (File file) async {
  dynamic tags = await _methodChannel.invokeMethod(
    'getMetaData', <dynamic>[file.absolute.path]
  );
  return tags 
}

// フォルダ探索
static dynamic getMetaDataFromEachEntry (dynamic[] paths) async {
  for (dynamic path in paths) {
    String pathString;
    if (path is String) {
      pathString = path;
    } else if (path is Directory) {
      pathString = path.toString();
    } else {
      throw StylishException('oi');
    }

    Directory dir = Directory(pathString);
    if (dir.existsSync()) {
      for (FileSystemEntity f in dir.listSync()) {
        if (f is File && isMusic(f)) {
          MusicDataStructure.add(f); // ここでgetMetaDataをコール？
        } else if (f is Directory) {
          getMetaDataFromEachEntry(f);
        }
      }
    }
  }
}
```

#### ツリー構造について
* ツリーを作るのではなく、フォルダー直下だけをDirectoryクラスで読み込む
  * https://api.flutter.dev/flutter/dart-io/Directory-class.html
* metaデータはFuture.builderを使って、フォルダーを開いた時にadd＆表示する



## MusicStructureの構造[☆]
```dart
class Music {
  String title;
  String artist;
  String albumArtist;
  String album;
  String genre;
  int _length;
  int get length => _length;
  Directory _path;
  Directory get path => _path;
  Image _jacket;
  Image get jackget => _jacket;

  Music.fromMetaData (dynamic meta) {//metaの型がわからｎ
    //つまりここもわｋらん
  }
}

static class MusicStructure {
  static Map<String, Music> _musicList = new Map<String, Music>();
  
  static void add (File f) async {
    var meta = await getMetaData(f);

    _musicList[f.absolute.path] = Music.fromMetaData(meta);
  }

  static void sort (SortType type) {
    int Function(Music, Music) aiueo;

    switch (type) {
      case SortType.Title: {
        aiueo = (music1, music2) {
          return music1.title.compareTo(music2.title);
        };
      }
      case SortType.Artist: {
        aiueo = (music1, music2) {
          return music1.artist.compareTo(music2.artist);
        };
      }
      // 以降同じイ
    }

    return _musicList.values.toList()..sort(aiueo);
  }
}
```





## Player
* バックグランド再生（フォアグラウンド再生？）
ここはおそらくJavaの領域．
### Javaの処理呼び出すやつ
```dart
static abstract class HogeHogePlayer {
  const MethodChannel _methodChannel = const MethodChannel('quiche');

  static bool init (String path) async {
    result = await _methodChannel.invokeMethod(
      'init', <dynamic>[path]
    );

    return result;
  }

  static bool play () async {
    result = await _methodChannel.invokeMethod(
      'play', <dynamic>[]
    );

    return result;
  }

  static bool repeat (int startTime, int endTime) async {
    result = await _methodChannel.invokeMethod(
      'repeat', <dynamic>[startTime, endTime]
    );

    return result;
  } // みたいな感じ
}
```

## MediaBrowserService [☆]
tutorialらしきもの:https://developer.android.com/guide/topics/media-apps/audio-app/building-a-mediabrowserservice
Qiitaの人気記事:https://qiita.com/siy1121/items/f01167186a6677c22435#クライアントからのmedia-sessionに対する要求を処理する
MediaBrowserServiceCompat:https://developer.android.com/reference/androidx/media/MediaBrowserServiceCompat
MediaSessionCompat:https://developer.android.com/reference/android/support/v4/media/session/MediaSessionCompat
MediaBrowserCompat.MediaItem:https://developer.android.com/reference/android/support/v4/media/MediaBrowserCompat.MediaItem

* Java側で``androidx.media.MediaBrowserServiceCompat``を用いてフォアグラウンドサービスを作成
* ``onLoadChildlen()``メソッドで固有のIDを持つ``MediaItem``オブジェクトを走査してくれるらしい．
* どうやってそのオブジェクトをDartと連携する？Java側だけで保持して，逐次``MethodChannel``からデータを受け取る？
一回``Bitmap``を配列に変換したりするから．パフォーマンス的にどうなの？
* 

### シークバーの更新について
* JavaからDartへ現在の再生時間を定期的に伝えることは多分無理
* Playする際に現在の再生時間も一緒にDartに伝えてDart側で数える？
* Timer クラスで１秒ごと（？）にjava側と同期してスライダーを動かす
  * https://api.dartlang.org/stable/2.6.1/dart-async/Timer-class.html
    * Timer.periodic tickじゃなくcounterを用意

