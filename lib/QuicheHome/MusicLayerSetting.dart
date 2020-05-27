import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/StackLayerType.dart';
import 'package:riot_quiche/QuicheHome/CustomizableWidget.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerSetting.dart';

import 'dart:math' as math;

import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerVarious.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/SelectLayer.dart';



class MusicLayerSetting extends StatefulWidget{
  final Function setLayer;
  final List<CustomizableWidget> layerList;
  final Size screenSize;
  MusicLayerSetting(this.setLayer, this.layerList, this.screenSize);

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
    widList = widget.layerList;
    numList = new List<int>.generate(widList.length, (i) => i);
    secNumList = new List<int>.generate(widList.length, (i) => i);
  }

  void callbackAddLayer(List<LayerProp> resultList, StackLayerType type){
    print('SnowAnimation_before');
    // widget ごとにswitchして、
    CustomizableWidget addWidget = StackLayerVariables.getAddLayer(type, resultList, widget.screenSize);

    print('SnowAnimation_after');
    print(addWidget);
    setState(() {
      widList.add(addWidget);
      numList.add(numList.length);
      secNumList.add(secNumList.length);
    });
  }

  void callbackSelectLayer(StackLayerType type){
    var list = StackLayerVariables.getLayerPropList(type);

    showDialog(
      context: context,
      builder: (_) {
        return LayerSetting(list, this.callbackAddLayer, type);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print(widList);
        widget.setLayer(widList);

        Navigator.of(context).pop(true);
        return new Future<bool>.value(false);
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: どのレイヤーを追加するか選ばせないといけない。本来なら画像で例示しながらCardみたいなのでやるべきだが...
            showDialog(
              context: context,
              builder: (_) {
                return SelectLayer(this.callbackSelectLayer);
              },
            );

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
                  "Back Ground Image",
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
              print('kokokawakaranaikedo');
              print(idx);
              print(secNumList);
              CustomizableWidget wid = widList[idx];
              int keyidx = numList[idx];
              return Card(
                elevation: 2.0,
                key: Key(keyidx.toString()),
                child: ListTile(
                  leading: Image.asset(wid.imagePath, fit: BoxFit.cover),
                  title: Text(wid.widgetNameJP),
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

