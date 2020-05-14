import 'package:flutter/material.dart';

import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Music/Album.dart';


class VariousSortTab extends StatefulWidget {
  final ValueNotifier<List<dynamic>> variousSortTabValueNotifier;
  final List<dynamic> listItem;

  VariousSortTab (
    this.listItem, this.variousSortTabValueNotifier, {Key key})
  : super(key: key);
  
  @override
  _VariousSortTabState createState () {
    return _VariousSortTabState();
  }
}

class _VariousSortTabState extends State<VariousSortTab> {
  List<dynamic> listItem, tmp;
  SortType nowSortType = SortType.TITLE_ASC;
  int nowLayer = 0;

  @override
  void initState () {
    super.initState();

    listItem = widget.listItem;
  }

  @override
  Widget build (BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    print('size: $size');

    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: _menu(),
        ),

        Expanded(
          child: ListView.separated(

            itemBuilder: (BuildContext context, int index) {
              if (index < listItem.length) {
                return GestureDetector(
                  onTap: (){
                    if (listItem[index] is Album){
                      setState(() {
                        tmp = listItem;
                        listItem = listItem[index].musics;
                        nowLayer++;
                      });
                    }else{
                      print('$index');
                      widget.variousSortTabValueNotifier.value = <dynamic>[listItem, index, nowLayer];
                      // widget.callback(listItem, index);
                      Navigator.of(context).pop();

                      //TODO　ここでlistitemを全部追加
                      //callbuck側になにかkeyを渡して、特定の場所から始める。

                    }

                  },
                  child: _seclist(index, size),
                );
              } else {
                return Divider(height: 100);
              }
            },
            itemCount: listItem.length + 1,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 1);
            },
          ),
        ),
      ]
    );
  }

  Widget _menu(){
    return ListTile(
      title: Text(nowSortType.toString().split('.')[1]),
      trailing: PopupMenuButton<SortType>(
        onSelected: (SortType result) {
          setState(() {
            nowSortType = result;
            listItem = QuicheOracleFunctions.getSortedMusicList(nowSortType);
          });
        },
        itemBuilder: (BuildContext context) {
          return SortType.values.map((SortType st) {
            return PopupMenuItem<SortType>(
              value: st,
              child: Text(st.toString()),
            );
          }).toList();
        },
      ),
    );

  }

  Widget _seclist(int index, Size size){
    var m = listItem[index];
    var jucketImage = m.getArt();
    if (jucketImage == null){
      jucketImage = Image.asset("images/dopper.jpg");
    }

//    var img = Image.network('https://pbs.twimg.com/media/EWm2AmcU4AID_2O?format=jpg&name=medium');
    var jacketSize = (size.height > size.width ? size.height: size.width) * 0.1;

    return Container(
      child: Row(
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                width: jacketSize,
                height: jacketSize,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: jucketImage.image,
                    )
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  height: jacketSize,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Expanded(
                        flex: 1,
                        child: Text(
                          listItem[index].title,
                          style: TextStyle(
                            fontSize: jacketSize / 4,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          listItem[index].artist,
                          style: TextStyle(
                            fontSize: jacketSize / 6,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),

          ]
      ),
    );

//    return Container(
//      child: ListTile(
//        leading: Container(
//          height: size.width * 0.1,
//          width: size.width * 0.1,
//          child: jucketImage,
//        ),
//        title: Text(listItem[index].title),
//        subtitle: Text(listItem[index].artist),
//        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueGrey,),
//      ),
//    );
  }
}