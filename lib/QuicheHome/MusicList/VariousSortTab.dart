import 'package:flutter/material.dart';
import 'package:riot_quiche/Enumerates/PopupMenuEnum.dart';

import 'package:riot_quiche/Enumerates/SortType.dart';
import 'package:riot_quiche/Music/Music.dart';
import 'package:riot_quiche/QuicheAssets.dart';
import 'package:riot_quiche/QuicheHome/MusicList/PopupMenu/PopupMenuForAddToPlaylist.dart';
import 'package:riot_quiche/QuicheHome/Widgets/AutoScrollText.dart';
import 'package:riot_quiche/QuicheOracle.dart';
import 'package:riot_quiche/Music/Album.dart';


class VariousSortTab extends StatefulWidget {
  
  final ValueNotifier<List<dynamic>> variousSortTabValueNotifier;
  final ValueNotifier<List<dynamic>> onPlaylistChangedNotifier;
  final ValueNotifier<List<dynamic>> onWillPopNotifier;


  VariousSortTab (
    this.variousSortTabValueNotifier,
    {
      Key key,
      @required this.onPlaylistChangedNotifier,
      @required this.onWillPopNotifier
    }
  ): super(key: key);
  
  @override
  _VariousSortTabState createState () {
    return _VariousSortTabState();
  }
}

class _VariousSortTabState extends State<VariousSortTab> with AutomaticKeepAliveClientMixin {
  //
  bool wantKeepAlive = true;
  //
  List<dynamic> listItem;
  static List<dynamic> tmp = [];
  static SortType nowSortType = SortType.TITLE_ASC;

  @override
  void initState () {
    super.initState();

    if (tmp.isEmpty) {
      listItem = QuicheOracleFunctions.getSortedMusicList(nowSortType);
      widget.onWillPopNotifier.value = <dynamic>[true];
    } else {
      listItem = tmp.removeLast();
      widget.onWillPopNotifier.value = <dynamic>[false];
    }

    print('VariousSorttab::initState()::widget.onWillPopNotifier.value: ${widget.onWillPopNotifier.value}');

    widget.onWillPopNotifier.addListener(() {
      bool shouldPop = widget.onWillPopNotifier.value[0];
      int index = widget.onWillPopNotifier.value[1];

      if (shouldPop && index == -1) {
        setState(() {
          if (tmp.isNotEmpty) {
            listItem = tmp.removeLast();
          }
        });
      } else if (shouldPop) {
        print('$index');
        widget.variousSortTabValueNotifier.value = <dynamic>[listItem, index];
      } else {
        setState(() {
          if (tmp.isEmpty) {
            tmp.add(listItem);
            listItem = listItem[index].musics;
          } else {
            widget.variousSortTabValueNotifier.value = <dynamic>[listItem, index];
          }
        });

          //TODO　ここでlistitemを全部追加
          //callbuck側になにかkeyを渡して、特定の場所から始める。
      }
    });
  }

  @override
  void dispose () {
    bool firstLayer = widget.onWillPopNotifier.value[0];
    print('VariousSortTab::dispose()::firstLayer: ${firstLayer}');
    if (!firstLayer) {
      tmp.add(listItem);
    }
    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    super.build(context);

    final Size size = MediaQuery.of(context).size;

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
                    if (listItem[index] is Album) {
                      widget.onWillPopNotifier.value = <dynamic>[false, index];
                    } else if (listItem[index] is Music && tmp.isEmpty) {
                      widget.onWillPopNotifier.value = <dynamic>[true, index];
                    } else {
                      widget.onWillPopNotifier.value = <dynamic>[false, index];
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
      jucketImage = QuicheAssets.icon;
    }

//    var img = Image.network('https://pbs.twimg.com/media/EWm2AmcU4AID_2O?format=jpg&name=medium');
    var jacketSize = (size.height > size.width ? size.height: size.width) * 0.1;

    Widget _popupMenu;
    if (m is Album) {
      _popupMenu = Container();
    } else {
      _popupMenu = PopupMenuButton<PopupMenuEnum>(
        onSelected: (PopupMenuEnum popupMenu) async {
          switch (popupMenu) {
            case PopupMenuEnum.AddToPlaylist: {
              await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 250, maxHeight: 400
                      ),
                      child: PopupMenuForAddToPlaylist(m)
                    )
                  );
                }
              );

              widget.onPlaylistChangedNotifier.value = <dynamic>[];
            }
          }
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<PopupMenuEnum>>[
            const PopupMenuItem<PopupMenuEnum>(
              value: PopupMenuEnum.AddToPlaylist,
              child: Text('Add to playlist')
            )
          ];
        }
      );
    }

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
                )
              )
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
                        child: AutoScrollText(
                          text: listItem[index].title,
                          textStyle: TextStyle(
                            fontSize: jacketSize / 4,
                          )
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: AutoScrollText(
                          text: listItem[index].artist,
                          textStyle: TextStyle(
                            fontSize: jacketSize / 6,
                          )
                        )
                      )
                    ]
                  )
                )
              )
            ),
            _popupMenu

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