import 'package:flutter/material.dart';
import 'package:riot_quiche/QuicheInitialization/NoneSection.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:riot_quiche/Enumerates/InitializationSection.dart';
import 'package:riot_quiche/Enumerates/RouteName.dart';

import 'package:riot_quiche/QuicheInitialization/IQuicheInitialization.dart';
import 'package:riot_quiche/QuicheInitialization/RequestPermissionsSection.dart';


class QuicheInitialization extends IQuicheInitialization {

  @override
  _QuicheInitializationState createState () {
    return _QuicheInitializationState();
  }
}

class _QuicheInitializationState extends State<QuicheInitialization> {
  final Map<InitializationSection, bool> _initializationResults = Map<InitializationSection, bool>();
  Map<InitializationSection, IQuicheInitialization> _sectionMap;
  InitializationSection _currentSection;

  SharedPreferences _prefs;


  @override
  void initState () {
    super.initState();

    _sectionMap = <InitializationSection, IQuicheInitialization>{
      InitializationSection.RequestPermissions: RequestPermissionsSection(
        onSuccess: () {
          print('RequestPermissions:onSuccess()');
          _initializationResults[InitializationSection.RequestPermissions] = true;
          _prefs.setBool(InitializationSection.RequestPermissions.toString(), true);
          setState(() {
            _currentSection = InitializationSection.None;
          });
        },
        onError: () {
          print('RequestPermissions:onError()');
          _initializationResults[InitializationSection.RequestPermissions] = false;
          _prefs.setBool(InitializationSection.RequestPermissions.toString(), false);
          setState(() {
            _currentSection = InitializationSection.None;
          });
        },
        nextSection: InitializationSection.None,
      ),
      InitializationSection.None: NoneSection(
        onSuccess: null, onError: null, nextSection: null
      )
    };

    _currentSection = InitializationSection.RequestPermissions;
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: FutureBuilder<InitializationSection>(
        future: _getNextSection(_currentSection),
        builder: (BuildContext context, AsyncSnapshot<InitializationSection> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting: {
              return Center(
                child: FlutterLogo()
              );

              break;
            }
            case ConnectionState.done: {
              _currentSection = snapshot.data;
              return _sectionMap[_currentSection];

              break;
            }
            default: {
              return Center(
                child: FlutterLogo()
              );

              break;
            }
          }
        },
      )
    );
  }

  /**
   * get next target section that have to be initialized
   */
  Future<InitializationSection> _getNextSection (InitializationSection section) async {
    InitializationSection targetSection = section;

    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    while (targetSection != InitializationSection.None) {
      if (!_prefs.containsKey(section.toString()) || !_prefs.getBool(section.toString())) {
        return targetSection;
      }
      targetSection = _sectionMap[targetSection].nextSection;
    }

    return InitializationSection.None;
  }
}