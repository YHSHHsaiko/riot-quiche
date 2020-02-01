import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riot_quiche/AndroidInvoker.dart';
import 'package:riot_quiche/Permissions.dart';

import 'package:riot_quiche/Settings.dart';
import 'package:riot_quiche/Utils.dart';

import 'package:riot_quiche/AndroidInvoker.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: EventChannelTest()
      )
    );
  }
}

class EventChannelTest extends StatelessWidget {

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _future(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: {
            return Text("*wait*");
          }
          case ConnectionState.done: {
            if (snapshot.hasError) {
              return Center(child: Text("*error*"));
            }
            return Center(child: Text("*done*"));
          }
          default: {
            return Text("*default*");
          }
        }
      },
    );
  }

  Future<Null> _future () async {
    // TODO: permission 考えようね～
    List<bool> res = await AndroidInvoker.requestPermissions(
      <Permissions>[
        Permissions.READ_EXTERNAL_STORAGE
      ]
    );

    print(res);
  }
}

class Test extends StatefulWidget {

  @override
  TestState createState () {
    return TestState();
  }
}

class TestState extends State<Test> {

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: AndroidInvoker.butterflyEffect(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List<String> miList = snapshot.data;
          print(miList);
          return ListView.builder(
            itemCount: miList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Icon(Icons.access_time),
                title: Text(miList[index]),
                onTap: () async {
                  await AndroidInvoker.init(miList[index]);
                  AndroidInvoker.play();
                },
              );
            }
          );
        } else if (snapshot.hasError) {
          return Text("Error!!!!!!");
        } else {
          return Text("wait....");
        }
      }
    );
  }

}

class TopMain extends StatelessWidget {

  @override
  Widget build (BuildContext context) {
    print('build TopMain.');
    
    Utils.screenWidth = MediaQuery.of(context).size.width;
    Utils.screenHeight = MediaQuery.of(context).size.height;

    Settings settings = Settings.load(1123421424);
    List<Widget> stackedLayers;
    for (String layerIdentifier in settings.stack) {
      
    }
  }
}