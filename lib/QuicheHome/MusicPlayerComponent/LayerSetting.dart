import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riot_quiche/Enumerates/StackLayerType.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerVarious.dart';


// List<LayerProp>を受け取って、resultを更新したList<LayerProp>を返す
class LayerSetting extends StatefulWidget{
  final List<LayerProp> layerPropList;
  final Function callback;
  final StackLayerType type;
  LayerSetting(this.layerPropList, this.callback, this.type);

  @override
  State<StatefulWidget> createState() => LayerSettingState();
}

class LayerSettingState extends State<LayerSetting>{

  List<LayerProp> layerPropList = [], layerPropList_false = [];
  List<TextEditingController> _textEditingControllerList = [];

  @override
  void initState() {
    super.initState();

    for (LayerProp lp_f in widget.layerPropList){
      if (lp_f.isSetting == true){
        layerPropList.add(lp_f);
      }else{
        layerPropList_false.add(lp_f);
      }
    }

    for (LayerProp lp in layerPropList){
      if (lp.layerPropType == LayerPropType.number || lp.layerPropType == LayerPropType.string){
        _textEditingControllerList.add(
            new TextEditingController(
              text: lp.result.toString(),
            )
        );
      }else{
        _textEditingControllerList.add(null);
      }
    }
    print('initState done.');
  }

  List<LayerProp> permByIndex(List<LayerProp> lp){
    print("sort_before");
    lp.sort((a, b) => a.index.compareTo(b.index));
    print("sort_after");
    return lp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Test")),
      body: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          LayerPropType type = layerPropList[index].layerPropType;
          switch (type) {
            case LayerPropType.number:
              return _numberListTile(index);
              break;
            case LayerPropType.color:
              return _colorListTile(index);
              break;
            case LayerPropType.boolean:
              return _booleanListTile(index);
              break;
            case LayerPropType.string:
              return _stringListTile(index);
              break;
          }
          return Text(index.toString());
        },
        itemCount: layerPropList.length,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //ここで、layerPropListとlayerPropList_falseを足して、indexで並べ替える。
          print("add_before");
          layerPropList.addAll(layerPropList_false);
          print("add_after");
          layerPropList = permByIndex(layerPropList);

          widget.callback(layerPropList, widget.type);
          Navigator.of(context).pop();
        },
        label: const Text('Add Layer'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  /// For Number ListTile.
  Widget _numberListTile(int index){
    print('make numberListTile');
    return ListTile(
      title: Text(layerPropList[index].entry),
      subtitle: layerPropList[index].description != null ? Text(layerPropList[index].description) : null,
      trailing: Container(
        height: 50,
        width: 100,//TODO: 幅を動的に変化させないといけない
        child: TextField(
          onChanged: (value){
            layerPropList[index].setResult(double.parse(value));
          },
          controller: _textEditingControllerList[index],
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  /// For Color ListTile.
  Widget _colorListTile(int index){
    ColorType _colorType = layerPropList[index].result;
    print('make colorListTile');
    return ListTile(
      title: Text(layerPropList[index].entry),
      subtitle: layerPropList[index].description != null ? Text(layerPropList[index].description) : null,
      trailing: Container(
        height: 50,
        width: 150,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: IconButton(
                icon: _shadowedIcon(Icons.arrow_left),
                color: ColorProp.getPrevColor(_colorType),
                onPressed: (){
                  setState((){
                    layerPropList[index].setResult(ColorProp.getPrevColorType(_colorType));
                  });
                },
              ),
            ),

            Expanded(
              flex: 2,
              child: Container(
                color: ColorProp.getColor(_colorType),
              ),
            ),

            Expanded(
              flex: 1,
              child: IconButton(
                icon: _shadowedIcon(Icons.arrow_right),
                color: ColorProp.getNextColor(_colorType),
                onPressed: (){
                  setState((){
                    layerPropList[index].setResult(ColorProp.getNextColorType(_colorType));
                  });
                }
              )
            )
          ]
        )
      )
    );
  }

  Widget _shadowedIcon (IconData iconData) {
    double iconSize = 20.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(40),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Icon(iconData, size: iconSize)
    );
  }

  /// For Boolean ListTile
  Widget _booleanListTile(int index){
    print('make booleanListTile');
    return ListTile(
      title: Text(layerPropList[index].entry),
      subtitle: layerPropList[index].description != null ? Text(layerPropList[index].description) : null,
      trailing: Container(
        height: 50,
        width: 100,//TODO: 幅を動的に変化させないといけない
        child: Checkbox(
          activeColor: Colors.blue,
          value: layerPropList[index].result,
          onChanged: (value){
            setState((){
              layerPropList[index].setResult(value);
            });
          },
        ),
      ),
    );
  }

  /// For String ListTile
  Widget _stringListTile(int index){
    print('make stringListTile');
    return ListTile(
      title: Text(layerPropList[index].entry),
      subtitle: layerPropList[index].description != null ? Text(layerPropList[index].description) : null,
      trailing: Container(
        height: 50,
        width: 100,//TODO: 幅を動的に変化させないといけない
        child: TextField(
          onChanged: (value){
            layerPropList[index].setResult(double.parse(value));
          },
          controller: _textEditingControllerList[index],
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

}


enum ColorType{
  white,
  black,
  red,
  orange,
  lightorange,
  yellow,
  lightgreen,
  green,
  bluegreen,
  lightblue,
  blue,
  bluepurple,
  purple,
  redpurple,
}

class ColorProp{
  static List<ColorType> _colorTypeValueList = ColorType.values;

  static List<Color> _colorList = [
    Color(0xffffffff),
    Color(0x00000000),
    Color(0xffef858c),
    Color(0xffef845c),
    Color(0xfff9c270),
    Color(0xfffff67f),
    Color(0xffc1db81),
    Color(0xff69bd83),
    Color(0xff61c1be),
    Color(0xff54c3f1),
    Color(0xff6c9bd2),
    Color(0xff796baf),
    Color(0xffba79b1),
    Color(0xffee87b4),
  ];

  static ColorType getNextColorType(ColorType type){
    return _colorTypeValueList[(type.index+1) % _colorTypeValueList.length];
  }

  static ColorType getPrevColorType(ColorType type){
    return _colorTypeValueList[(type.index-1) % _colorTypeValueList.length];
  }

  static Color getColor(ColorType type){
    return _colorList[type.index];
  }

  static Color getNextColor(ColorType type){
    return _colorList[getNextColorType(type).index];
  }

  static Color getPrevColor(ColorType type){
    return _colorList[getPrevColorType(type).index];
  }
}

