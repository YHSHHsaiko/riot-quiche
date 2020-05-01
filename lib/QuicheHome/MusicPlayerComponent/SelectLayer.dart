import 'package:flutter/material.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/CircleMine.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/Layer/SnowAnimation.dart';
import 'package:riot_quiche/QuicheHome/MusicPlayerComponent/LayerVarious.dart';

class SelectLayer extends StatelessWidget {
  final Function callback;
  SelectLayer(this.callback);

  @override
  Widget build(BuildContext context) {
    var grid = [SnowAnimation.imagePath,CircleMine.imagePath];
    var grid2 = [StackLayerType.SnowAnimation,StackLayerType.Circle];
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('GridView'),
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
            ),
//            body: GridView.builder(
//                itemCount: grid.length,
//                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                  crossAxisCount: 2,
//                ),
//                itemBuilder: (BuildContext con, int index) {
//                  print(index);
//                  return _item(grid[index], grid2[index], context);
//                }
//            )
        )
    );
  }

  Widget _item(String imgPath, StackLayerType type, BuildContext context) {
//    return Card(
//      child: GestureDetector(
//        onTap: (){
//          print('1');
//          Navigator.of(context).pop();
//          print('2');
//          callback(type);
//          print('3');
//        },
//        child: Text(type.toString()),
//      ),
//      color: Colors.green,
//    );

    var radius = 20.0;
    var color = Colors.grey;

    return GestureDetector(
      onTap: (){
//      callback(color.toString());
        Navigator.of(context).pop();
        callback(type);
      },
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius)),
          ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.0),
//           ),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
//             boxShadow: [
//               new BoxShadow(
//                 color: Colors.grey,
//                 offset: new Offset(5.0, 5.0),
//                 blurRadius: 10.0,
//               )
//             ],
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

//Widget _item(Color color) {
//  var radius = 20.0;
//
//  return GestureDetector(
//    onTap: (){
////      callback(color.toString());
//      print('a');
//    },
//    child: ClipPath(
//      clipper: ShapeBorderClipper(
//        shape: BeveledRectangleBorder(
//          borderRadius: BorderRadius.only(topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius)),
//        ),
////           shape: RoundedRectangleBorder(
////             borderRadius: BorderRadius.circular(10.0),
////           ),
//      ),
//      child: Container(
//        alignment: Alignment.center,
//        decoration: BoxDecoration(
//          color: Colors.blueGrey,
////             boxShadow: [
////               new BoxShadow(
////                 color: Colors.grey,
////                 offset: new Offset(5.0, 5.0),
////                 blurRadius: 10.0,
////               )
////             ],
//          border: Border(
//            left: BorderSide(
//              width: 5,
//              color: color,
//            ),
//          ),
//        ),
//        child:ClipRRect(
//          child: Column(
//              children: <Widget>[
//                Image.network('https://pbs.twimg.com/media/EWMuXehUwAIBkhS?format=jpg&name=large', fit: BoxFit.cover),
//                Expanded(
//                  child: Center(
//                    child: Text(
//                      'SnowAnimation',
//                      style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 20,
//                      ),
//                    ),
//                  ),
//                ),
//              ]
//          ),
//        ),
//      ),
//    ),
//  );
//}