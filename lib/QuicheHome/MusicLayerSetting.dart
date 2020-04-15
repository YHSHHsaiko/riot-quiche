import 'package:flutter/material.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';

import 'dart:math' as math;



class MusicLayerSetting extends StatefulWidget{
  Function setLayer;
  List<Widget> layerList;
  MusicLayerSetting(this.setLayer, this.layerList);

  @override
  State<StatefulWidget> createState() => MusicLayerSettingState();
}

class MusicLayerSettingState extends State<MusicLayerSetting>{

//  List<int> widgetList = [];
  List<CustomizableWidget> widList;
  List<int> numList;
  List<int> secNumList;

  @override
  void initState() {
    super.initState();
    print(widget.layerList);
    print(widList);
    widList = widget.layerList.cast<CustomizableWidget>();
    numList = new List<int>.generate(widList.length, (i) => i);
    secNumList = new List<int>.generate(widList.length, (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print(widList);
        widget.setLayer(widList.cast<Widget>());
        return new Future<bool>.value(true);
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            var rnd = math.Random();
            int js = rnd.nextInt(150);

            Widget w = CircleMine(
              screenSize: Size(300, 500),
              diameter: 300.0+js,
              color: Colors.green,
              strokeWidth: 2,
            );

            print('FAB:setState');

            setState(() {
              widList.add(w);
              numList.add(numList.length);
              secNumList.add(secNumList.length);
            });
          },
          label: Text('Add Layer'),
          icon: Icon(Icons.add),
          backgroundColor: Colors.pink,
        ),
        body: Container(
          child: ReorderableListView(
            padding: EdgeInsets.all(10.0),
            header: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Here is BackGround.",
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              CustomizableWidget idx = widList.removeAt(oldIndex);
              int numidx = numList.removeAt(oldIndex);

              setState(() {
                widList.insert(newIndex, idx);
                numList.insert(newIndex, numidx);
              });
            },
            children: secNumList.map((int idx) {
              CustomizableWidget wid = widList[idx];
              int keyidx = numList[idx];
              return Card(
                elevation: 2.0,
                key: Key(keyidx.toString()),
                child: ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(wid.layerType.toString()),
                  subtitle: Text("sub:$keyidx:"+wid.layerType.toString()),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

