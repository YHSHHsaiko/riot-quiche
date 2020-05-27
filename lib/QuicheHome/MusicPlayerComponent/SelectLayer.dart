import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/StackLayerType.dart';
import 'package:riot_quiche/QuicheAssets.dart';


class SelectLayer extends StatelessWidget {
  final Function callback;
  SelectLayer(this.callback);

  @override
  Widget build(BuildContext context) {
    var grid = [QuicheAssets.iconPath, QuicheAssets.iconPath];
    var grid2 = [StackLayerType.SnowAnimation,StackLayerType.CircleMine];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GridView'),
        ),
        body: GridView.count(
          padding: EdgeInsets.all(8.0),
          crossAxisCount: 2,
          crossAxisSpacing: 6.0, // 縦
          mainAxisSpacing: 6.0, // 横
          childAspectRatio: 0.76, // 高さ
          shrinkWrap: true,
          children: List.generate(grid.length, (index) {
            return _item(grid[index], grid2[index], context);
          }),
        )
      )
    );
  }

  Widget _item(String imgPath, StackLayerType type, BuildContext context) {
    var radius = 20.0;
    var color = Colors.grey;

    return GestureDetector(
      onTap: (){
        Navigator.of(context).pop();
        callback(type);
      },
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius)),
          )
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            border: Border(
              left: BorderSide(
                width: 5,
                color: color,
              ),
            ),
          ),
          child:ClipRRect(
            child: Column(
                children: <Widget>[
                  Image.asset(imgPath, fit: BoxFit.cover),
                  Expanded(
                    child: Center(
                      child: Text(
                        type.toString().split('.')[1],//'SnowAnimation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }
}