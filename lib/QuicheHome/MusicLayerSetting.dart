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

  //
  bool editMode;
  List<bool> checkBoxList;


  @override
  void initState() {
    super.initState();
    print(widget.layerList);
    print(widList);

    widList = widget.layerList;

    editMode = false;
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
    if (!editMode) {
      numList = List<int>.generate(widList.length, (i) => i);
      secNumList = List<int>.generate(widList.length, (i) => i);
      checkBoxList = List<bool>.filled(widList.length, true);
    }

    Widget floatingActionContents = _buildFloatingActionContents();
    Widget layerView = _buildLayerView();

    return WillPopScope(
      onWillPop: () {
        print(widList);
        widget.setLayer(widList);

        Navigator.of(context).pop<List<CustomizableWidget>>(widList);
        return new Future<bool>.value(false);
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: floatingActionContents,
        body: Container(
          child: layerView
        ),
      ),
    );
  }


  Widget _buildFloatingActionContents () {
    if (editMode) {
      return  FloatingActionButton(
        onPressed: () {
          setState(() {
            editMode = false;
            _editLayer();
          });
        },
        backgroundColor: Colors.deepOrangeAccent[100],
        child: const Icon(Icons.check)
      );
    } else {
      return Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: FloatingActionButton.extended(
              onPressed: () {
                // TODO: どのレイヤーを追加するか選ばせないといけない。本来なら画像で例示しながらCardみたいなのでやるべきだが...
                showDialog(
                  context: context,
                  builder: (_) {
                    return SelectLayer(this.callbackSelectLayer);
                  },
                );
              },
              label: Text('      Add Layer'),
              icon: Icon(Icons.add),
              backgroundColor: Colors.pink
            )
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  editMode = true;
                });
              },
              label: Text('Remove Layer'),
              icon: Icon(Icons.remove),
              backgroundColor: Colors.blueAccent,
            )
          )
        ]
      );
    }
  }

  Widget _buildLayerView () {
    if (editMode) {
      return ListView(
        padding: EdgeInsets.all(10.0),
        children: secNumList.map((int idx) {
          CustomizableWidget wid = widList[idx];
          int keyidx = numList[idx];
          return Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 2.0,
                  key: Key(keyidx.toString()),
                  child: ListTile(
                    leading: Image.asset(wid.imagePath, fit: BoxFit.cover),
                    title: Text(wid.widgetNameJP),
                    subtitle: Text("sub:$keyidx:"+wid.layerType.toString()),
                  )
                )
              ),
              Expanded(
                flex: 1,
                child: Checkbox(
                  value: checkBoxList[idx],
                  onChanged: (bool newValue) {
                    setState(() {
                      checkBoxList[idx] = newValue;
                    });
                  }
                )
              )
            ]
          );
        }).toList(),
      );
    } else {
      return ReorderableListView(
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
      );
    }
  }

  void _editLayer () {
    List<CustomizableWidget> deleteList = <CustomizableWidget>[];

    for (int i = 0; i < checkBoxList.length; ++i) {
      if (!checkBoxList[i]) {
        deleteList.add(widList[i]);
      }
    }

    for (CustomizableWidget targetWidget in deleteList) {
      widList.remove(targetWidget);
    }
  }
}