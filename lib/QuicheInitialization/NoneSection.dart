import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/InitializationSection.dart';

import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/Enumerates/RouteName.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheInitialization/IQuicheInitialization.dart';
import 'package:riot_quiche/QuicheOracle.dart';


class NoneSection extends IQuicheInitialization {

  NoneSection ({
    @required void Function() onSuccess,
    @required void Function() onError,
    @required InitializationSection nextSection,
    Key key,
  })
  : super(key: key, onSuccess: onSuccess, onError: onError, nextSection: nextSection);

  @override
  _NoneSectionState createState () {
    return _NoneSectionState();
  }
}

class _NoneSectionState extends State<NoneSection> {
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );


  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _welcomeUntil(context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Center(
          child:  FlutterLogo()
        );
      }
    );
  }

  /**
   * TODO:
   * decide what we do actually
   */
  Future<Null> _welcomeUntil (BuildContext context) async {
    await Future.delayed(Duration(microseconds: 100));

    Navigator.of(context).pushReplacementNamed(RouteName.Home.name);
  }
}