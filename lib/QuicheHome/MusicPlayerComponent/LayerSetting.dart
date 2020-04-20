import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  List<LayerProp> layerPropList;
  List<TextEditingController> _textEditingControllerList = [];

  @override
  void initState() {
    super.initState();
    layerPropList = widget.layerPropList;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List Test"),),
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
        itemCount: widget.layerPropList.length,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.callback(layerPropList, widget.type);
          Navigator.of(context).pop();
        },
        label: Text('Add Layer'),
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
                icon: Icon(Icons.arrow_left),
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
                icon: Icon(Icons.arrow_right),
                color: ColorProp.getNextColor(_colorType),
                onPressed: (){
                  setState((){
                    layerPropList[index].setResult(ColorProp.getNextColorType(_colorType));
                  });
                },
              ),
            ),
          ],
        ),
      ),
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
  red,
  orange,
  green,
  blue,
}

class ColorProp{
  static List<ColorType> _colorTypeValueList = ColorType.values;

  static List<Color> _colorList = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
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