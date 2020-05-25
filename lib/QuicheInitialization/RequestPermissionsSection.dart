import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/InitializationSection.dart';

import 'package:riot_quiche/Enumerates/Permission.dart';
import 'package:riot_quiche/PlatformMethodInvoker.dart';
import 'package:riot_quiche/QuicheInitialization/IQuicheInitialization.dart';
import 'package:riot_quiche/QuicheOracle.dart';


class RequestPermissionsSection extends IQuicheInitialization {

  RequestPermissionsSection ({
    @required void Function() onSuccess,
    @required void Function() onError,
    @required InitializationSection nextSection,
    Key key,
  })
  : super(key: key, onSuccess: onSuccess, onError: onError, nextSection: nextSection);

  @override
  _RequestPermissionsSectionState createState () {
    return _RequestPermissionsSectionState();
  }
}

class _RequestPermissionsSectionState extends State<RequestPermissionsSection> {
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  Widget _utilityButton;


  @override
  void initState () {
    super.initState();

    _pageController.addListener(() {
    });

    _utilityButton = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: FlatButton(
            onPressed: () async {
              List<bool> isGranted = await PlatformMethodInvoker.requestPermissions(Permission.values);

              for (int i = 0; i < Permission.values.length; ++i) {
                if (isGranted[i]) {
                  print('permission is granted: ${Permission.values[i]}');
                  QuicheOracleVariables.permissionInformation[Permission.values[i]] = true;

                  switch (Permission.values[i]) {
                    case Permission.READ_EXTERNAL_STORAGE: {
                      break;
                    }
                    default: {
                      break;
                    }
                  }
                } else {
                  print('permission is not granted: ${Permission.values[i]}');
                  QuicheOracleVariables.permissionInformation[Permission.values[i]] = false;

                  switch (Permission.values[i]) {
                    case Permission.READ_EXTERNAL_STORAGE: {
                      break;
                    }
                    default: {
                      break;
                    }
                  }
                }
              }

              if (isGranted.contains(false)) {
                widget.onError();
              } else {
                widget.onSuccess();
              }

            },
            child: Text(
              "わかりました！",
              style: TextStyle(decoration: TextDecoration.underline)
            )
          )
        )
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

  @override
  Widget build (BuildContext context) {
    return Stack(
      children: <Widget>[
        PageView(
          controller: _pageController,
          children: <Widget>[
            // ここに各説明を挿入
            _PermissionExplanation1(),
          ],
          onPageChanged: (int p) => _onPageChanged(context, p),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _utilityButton
        )
      ],
      fit: StackFit.expand,
    );
  }

  void _onPageChanged (BuildContext context, int p) {

  }
}


/*
 * - permission 1:
 *  read_external_storage
 * - Summary:
 *  To read external storage to play the music in SD-card, or others.
 */
class _PermissionExplanation1 extends StatelessWidget {

  const _PermissionExplanation1 ({
    Key key
  })
  : super(key: key);
  
  @override
  Widget build (BuildContext context) {
    return Center(
      child: const Text('''
        このアプリを起動するには、
        ストレージアクセス権限が必要です。
        
        ご理解ご協力のほど、よろしくお願い致します！
      ''')
    );
  }
}