import 'package:flutter/material.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerVarious.dart';

class SelectLayer extends StatelessWidget {
  final Function callback;
  SelectLayer(this.callback);

  @override
  Widget build(BuildContext context) {
    var grid = [Colors.red,Colors.blue,Colors.green];
    var grid2 = [StackLayerType.SnowAnimation,StackLayerType.Circle,StackLayerType.SnowAnimation];
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('GridView'),
            ),
            body: GridView.builder(
                itemCount: grid.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (BuildContext con, int index) {
                  print(index);
                  return _item(grid[index], grid2[index], context);
                }
            )
        )
    );
  }

  Widget _item(Color color, StackLayerType type, BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: (){
          print('1');
          Navigator.of(context).pop();
          print('2');
          callback(type);
          print('3');
        },
        child: Text(type.toString()),
      ),
      color: color,
    );
  }
}