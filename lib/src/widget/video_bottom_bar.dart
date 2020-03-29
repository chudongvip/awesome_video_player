import 'package:flutter/material.dart';

import "../video_control_bar_style.dart";

class VideoBottomBar extends AnimatedWidget {
  VideoBottomBar(
      {Key key,
      Animation<double> animation,
      this.children,
      VideoControlBarStyle videoControlBarStyle})
      : videoControlBarStyle = videoControlBarStyle ?? VideoControlBarStyle(),
        super(key: key, listenable: animation);

  final VideoControlBarStyle videoControlBarStyle;
  final List<Widget> children;

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    return Positioned(
      bottom: animation.value,
      left: 0,
      right: 0,
      child: Container(
        margin: videoControlBarStyle.margin,
        padding: videoControlBarStyle.padding,
        height: videoControlBarStyle.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.transparent, videoControlBarStyle.barBackgroundColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
