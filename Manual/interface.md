<!-- TOC -->

- [アプリの流れ](#アプリの流れ)
- [Splash](#splash)
  - [フォルダ](#フォルダ)
  - [概要](#概要)
  - [説明](#説明)
  - [どうすればええの？](#どうすればええの)
- [Entrance](#entrance)
  - [フォルダ](#フォルダ-1)
  - [概要](#概要-1)
  - [説明](#説明-1)
  - [どうすればええの？](#どうすればええの-1)
- [Initialization](#initialization)
  - [フォルダ](#フォルダ-2)
  - [概要](#概要-2)
  - [説明](#説明-2)
  - [どうすればええの？](#どうすればええの-2)
- [Home](#home)
  - [フォルダ](#フォルダ-3)
  - [概要](#概要-3)
  - [説明](#説明-3)
  - [どうすればええの？](#どうすればええの-3)
- [QuicheOracle](#quicheoracle)
  - [ファイル](#ファイル)
  - [概要](#概要-4)
  - [説明](#説明-4)
    - [QuicheOracleVariables](#quicheoraclevariables)
    - [QuicheOracleFunctions](#quicheoraclefunctions)
- [PlatformMethodInvoker](#platformmethodinvoker)
  - [ファイル](#ファイル-1)
  - [概要](#概要-5)
  - [説明](#説明-5)
    - [](#)
      - [どうすればええの？](#どうすればええの-4)
    - [](#-1)
      - [どうすればええの？](#どうすればええの-5)
    - [](#-2)
      - [どうすればええの？](#どうすればええの-6)
    - [](#-3)
      - [どうすればええの？](#どうすればええの-7)
    - [](#-4)
      - [どうすればええの？](#どうすればええの-8)
    - [](#-5)
      - [どうすればええの？](#どうすればええの-9)
- [Enumerates](#enumerates)
  - [InitializationSection](#initializationsection)
  - [Permission](#permission)
  - [RouteName](#routename)
  - [SortType](#sorttype)

<!-- /TOC -->

# アプリの流れ
![この画像を見ÿと](image/app_flow.png)

# Splash
## フォルダ
QuicheSplash

## 概要
アプリの印象をよくするためのアニメー朱恩．

## 説明
``main.dart``の``_animateUntil``関数にて，Futureとして``delayed``とコンストラクタの引数である``someFuture``([ここで渡す](#main.dart))が両方とも終わるまでスプラッシュアニメーションを繰り返す．
## どうすればええの？
* ``someFuture``を渡して，
* Futureが両方終わるまでのアニメーションを``build``関数に定義すればよい．


# Entrance
## フォルダ
QuicheEntrance

## 概要
アプリの玄関．

## 説明
``QuicheOracleFunctions.checkInitialization``([ここで定義する](#QuicheOracleFunctions))関数でアプリ既に初期化されたか(初回起動時かどうか，もしくは正常に初期化されたか，のほうが安全？)を見て，
* ``true``なら[Home](#Home)に行き，
* ``false``なら[Initialization](#Initialization)に行く．

## どうすればええの？
``QuicheOracleFunctions.checkInitialization``の中身を頑張る．



# Initialization
## フォルダ
QuicheInitialization

## 概要
アプリの初期化．

## 説明
``IQuicheInitialization``の継承クラスを``_sectionMap``に挿入し，``onSuccess``や``onError``等に基づき初期化が構成される．

## どうすればええの？
* 現状``RequestPermissionsSection``だけなので，
* なにも考えなくてよいで宇s．



# Home
## フォルダ
QuicheHome

## 概要
アプリのメイン画面．

## 説明
<font size="5">**今のところ，何も考えてません！**</font>

## どうすればええの？
* **ここでアプリの本気の見せどころ**
* ``QuicheOracle``([これです](#QuicheOracle))や``PlatformMethodInvoker``([これです](#PlatformMethodInvoker))を駆使して頑張ってください！




# QuicheOracle
## ファイル
``QuicheOracle.dart``

## 概要
アプリの汎用インターフェース．

## 説明
### QuicheOracleVariables
* ``screenWidth``
今は何も考えてない
* ``screenHeight``
今は何も考えてない
* ``musicList``
ここにネイティブから取得したメディアの情報を保持する``Music``クラスが詰まっています．
* ``permissionInformation``
パーミッション情報です．**触れるな危険**
* ``serializedJsonDirectory``
今は何も考えてない．ここに``CustomizableWidget``のセッティングJSONを入れたい


### QuicheOracleFunctions
* ``checkInitialization()``
アプリが初回起動かどうか(アプリが正常に初期化されたかどうか)を判定する関数．
* ``getSortedMusicList(SortType sortType)``
``SortType``enumに応じてソートした``List<Music>``を返します．
  - **考えなければならないこと**
  ``Music``クラスは現状**1曲単位**です．例としてアルバムソートの場合，多数の
  ``Music``クラスをhasした``Album``クラス等を考えてみると酔うかもしれません．


# PlatformMethodInvoker
## ファイル
``PlatformMethodInvoker.dart``

## 概要
androidネイティブAPIを呼び出す関数が多数勢ぞろい

## 説明
* * *
### 
```dart
static Future<List<bool>> requestPermissions (List<Permission> permissions) async
```
パーミッションを要求します．acceptされれば``true``，denyされれば``false``がそれぞれ戻り値のリストに格納されます．
#### どうすればええの？
パーミッションを必要としない限り，呼ぶ必要はありません．

* * *
### 
```dart
static Future<bool> trigger () async
```
MediaBrowserServiceをアプリにバインドします．
#### どうすればええの？
Homeの起動時に呼ばれるものです．気にする必要はありません．

* * *
### 
```dart
static Future<List<Music>> butterflyEffect () async
```
ネイティブから再生できるミュージックを全て取得します．
#### どうすればええの？
Homeに来た時点で既に``QuicheOracleFunctions.musicList``に全て格納されています．気にする必要はありません．
**取得する属性を追加したい場合は，Javaコードを変更する必要があります．！**

* * *
### 
```dart
static Future<Null> setQueue (List<String> mediaIdList) async
```
``Music``クラスの``id``プロパティのリストを引数にして，それに対応するキューをネイティブで作成します．
#### どうすればええの？
たとえば，アルバムをクリックした場合，キューにアルバム内の``Music``の``id``を順番に入れる必要があります．

* * *
### 
```dart
static Future<Null> setCurrentMediaId (String mediaId) async
```
``play``を呼び出す前に，この関数を呼び出して準備します．引数には``Music``クラスの``id``を指定します．
#### どうすればええの？
正しく使ってください．

* * *
### 
```dart
static Future<Null> play () async
```
現在セットされているメディアを再生します．
#### どうすればええの？
正しく使ってください．




# Enumerates
## InitializationSection
```dart
  RequestPermissions,
  None
```
## Permission
```dart
  READ_EXTERNAL_STORAGE
```
## RouteName
```dart
  Splash,
  Entrance,
  Initialization,
  Home
```
* extension メソッド
```dart
  String get name {
    switch (this) {
      case RouteName.Splash: {
        return '/';
      }
      case RouteName.Entrance: {
        return '/entrance';
      }
      case RouteName.Initialization: {
        return '/initialization';
      }
      case RouteName.Home: {
        return '/home';
      }
    }
  }
```
## SortType
```dart
  TITLE_ASC,
  ARTIST_ASC,
  ALBUM_ASC,
  TITLE_DESC,
  ARTIST_DESC,
  ALBUM_DESC
```