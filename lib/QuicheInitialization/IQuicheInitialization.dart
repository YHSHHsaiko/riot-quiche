import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/InitializationSection.dart';


class IQuicheInitialization extends StatefulWidget {
  final void Function() onSuccess;
  final void Function() onError;
  final InitializationSection nextSection;


  IQuicheInitialization ({
    @required void Function() onSuccess,
    @required void Function() onError,
    @required InitializationSection nextSection,
    Key key,
  })
  : this.onSuccess = onSuccess,
    this.onError = onError,
    this.nextSection = nextSection,
    super(key: key);
  
  @override
  State createState () {}
}