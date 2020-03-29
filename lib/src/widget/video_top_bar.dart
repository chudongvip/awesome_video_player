import 'package:flutter/material.dart';

import "../video_top_bar_style.dart";
import "../video_control_bar_style.dart";

class VideoTopBar extends AnimatedWidget {
  VideoTopBar(
      {Key key,
      Animation<double> animation,
      VideoControlBarStyle videoControlBarStyle,
      VideoTopBarStyle videoTopBarStyle,
      this.onpop})
      : videoTopBarStyle = videoTopBarStyle ?? VideoTopBarStyle(),
        videoControlBarStyle = videoControlBarStyle ?? VideoControlBarStyle(),
        super(key: key, listenable: animation);

  final VideoTopBarStyle videoTopBarStyle;
  final VideoControlBarStyle videoControlBarStyle;
  final Function onpop;

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    return videoTopBarStyle.customBar == null
        ? Positioned(
            top: animation.value,
            left: 0,
            right: 0,
            // alignment: Alignment.topLeft,
            child: Container(
              margin: videoTopBarStyle.margin,
              padding: videoTopBarStyle.padding,
              height: videoTopBarStyle.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  videoControlBarStyle.barBackgroundColor,
                  Colors.transparent
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  /// 返回按钮
                  GestureDetector(
                    onTap: () {
                      if (onpop != null) {
                        onpop();
                      }
                    },
                    child: videoTopBarStyle.popIcon,
                  ),

                  /// 中部控制栏
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: videoTopBarStyle.contents,
                    ),
                  ),

                  /// 右侧部控制栏
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: videoTopBarStyle.actions,
                  )
                ],
              ),
            ),
          )
        : videoTopBarStyle.customBar;
  }
}
