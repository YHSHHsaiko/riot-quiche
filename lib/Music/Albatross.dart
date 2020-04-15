abstract class Albatross{
  final String _id;
  String get id => _id;
  final String _albumId;
  String get albumId => _albumId;
  final String _title;
  String get title => _title;
  
  Albatross(
    this._id,
    this._albumId,
    this._title,
  );
}