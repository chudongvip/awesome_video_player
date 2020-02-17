import 'package:flutter/material.dart';

class VideoProgressStyle {
  VideoProgressStyle({
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
    this.dragBarColor = const Color.fromRGBO(255, 255, 255, 1),
    this.progressRadius = 4,
    this.height = 4,
    this.dragHeight = 5,
    // this.dargBarIcon = const ,
  });

  final EdgeInsets padding;
  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final Color dragBarColor;
  final double progressRadius;
  final double height;
  final double dragHeight;
  // final Widget dargBarIcon;
}
