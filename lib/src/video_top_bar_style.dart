import 'package:flutter/material.dart';

/// 进度条样式
class VideoTopBarStyle {
  VideoTopBarStyle({
    this.show = true,
    this.height = 36,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    this.barBackgroundColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.popIcon = const Icon(
      Icons.arrow_back,
      size: 18,
      color: Colors.white,
    ),
    this.contents = const [],
    this.actions = const [],
    this.customBar,
  });

  final bool show;
  final double height;
  EdgeInsets margin;
  final EdgeInsets padding;
  final Color barBackgroundColor;
  final Widget popIcon;
  final List<Widget> contents;
  final List<Widget> actions;
  final Widget customBar;
}
