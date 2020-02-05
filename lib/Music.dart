class Music {
  final String _id;
  String get id => _id;
  final String _title;
  String get title => _title;
  final String _artist;
  String get artist => _artist;
  final String _album;
  String get album => _album;
  final int _duration;
  int get duration => _duration;
  final String _artUri;
  String get artUri => _artUri;

  
  Music (
    this._id,
    this._title,
    this._artist,
    this._album,
    this._duration,
    this._artUri
  );
}