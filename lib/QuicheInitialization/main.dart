import 'package:flutter/material.dart';
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

  @override
  void initState () {
    super.initState();

    _sectionMap = <InitializationSection, IQuicheInitialization>{
      InitializationSection.RequestPermissions: RequestPermissionsSection(
        onSuccess: () {
          _initializationResults[InitializationSection.RequestPermissions] = true;
          setState(() {
            _currentSection = InitializationSection.None;
          });
        },
        onError: () {
          _initializationResults[InitializationSection.RequestPermissions] = false;
          setState(() {
            _currentSection = InitializationSection.None;
          });
        }
      ),
      InitializationSection.None: null
    };

    _currentSection = InitializationSection.RequestPermissions;
  }

  @override
  Widget build (BuildContext context) {
    if (_currentSection == InitializationSection.None) {
      return Scaffold(
        body: FutureBuilder(
          future: _welcomeUntil(context),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Center(
              child: FlutterLogo()
            );
          },
        )
      );
    } else {
      return Scaffold(
        body: _sectionMap[_currentSection]
      );
    }
  }

  /**
   * TODO:
   * decide what we do actually
   */
  Future<Null> _welcomeUntil (BuildContext context) async {
    await Future.delayed(Duration(seconds: 2));

    Navigator.of(context).pushReplacementNamed(RouteName.Home.name);
  }
}