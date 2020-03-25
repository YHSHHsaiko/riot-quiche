import 'dart:ui';
import 'package:flutter/material.dart';

class BackGround extends StatelessWidget{
  ImageProvider img;
  BackGround(this.img);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
//        foregroundDecoration: BoxDecoration(
//          color: Colors.grey,
//          backgroundBlendMode: BlendMode.saturation,
//        ),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: img,
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRRect( // make sure we apply clip it properly
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              alignment: Alignment.center,
              //color: Colors.black26.withOpacity(0.1).withAlpha(150),
              color: Colors.grey.withOpacity(0.1),//.withAlpha(100),
            ),
          ),
        ),
      ),
    );
  }

}

