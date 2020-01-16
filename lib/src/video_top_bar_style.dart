import 'package:flutter/material.dart';

/// 进度条样式
class VideoTopBarStyle {
  VideoTopBarStyle({
    this.show = true,
    this.height = 30,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    this.barBackgroundColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.popIcon = const Icon(
      Icons.arrow_back,
      size: 16,
      color: Colors.white,
    ),
    this.contents = const [],
    this.actions = const [],
    this.customBar,
  });

  final bool show;
  final double height;
  final EdgeInsets padding;
  final Color barBackgroundColor;
  final Widget popIcon;
  final List<Widget> contents;
  final List<Widget> actions;
  final Widget customBar;
}
