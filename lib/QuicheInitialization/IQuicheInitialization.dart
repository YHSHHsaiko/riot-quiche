import 'package:flutter/material.dart';


class IQuicheInitialization extends StatefulWidget {
  final void Function() onSuccess;
  final void Function() onError;


  const IQuicheInitialization ({
    @required void Function() onSuccess,
    @required void Function() onError,
    Key key,
  })
  : this.onSuccess = onSuccess,
    this.onError = onError,
    super(key: key);
  
  @override
  State createState () {}
}