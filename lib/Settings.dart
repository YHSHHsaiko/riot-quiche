class Settings {
  var json = '''
  {
    "stack": [
      "widget1",
      "widget2",
    ],
    "setting": [
      "widget1": [
        "option1": 11,
        "option2": 11
      ],
      "widget2": [],
      "widget3": [],
    ]
  }
  ''';
  List<String> _stack;
  List<String> get stack {
    return _stack;
  }
  Map<String, dynamic> _setting;
  Map<String, dynamic> get setting {
    return _setting;
  }
  bool _success;
  bool get success { return _success; }


  // save settings.json 
  Settings.save (dynamic) {
    _success = true;
  }

  // load settings.json
  Settings.load (dynamic) {
    _success = true;
  }

}