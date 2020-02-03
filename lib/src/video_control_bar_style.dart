import 'package:flutter/material.dart';

/// 进度条样式
class VideoControlBarStyle {
  VideoControlBarStyle({
    this.height = 30,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
    this.barBackgroundColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.playIcon = const Icon(
      Icons.play_circle_outline,
      size: 16,
      color: Color(0xFFFFFFFF),
      semanticLabel: "播放",
    ),
    this.pauseIcon = const Icon(
      Icons.pause_circle_outline,
      size: 16,
      color: Color(0xFFFFFFFF),
      semanticLabel: "暂停",
    ),
    this.rewindIcon = const Icon(
      Icons.fast_rewind,
      size: 16,
      color: Color(0xFFFFFFFF),
      semanticLabel: "快退",
    ),
    this.forwardIcon = const Icon(
      Icons.fast_forward,
      size: 16,
      color: Color(0xFFFFFFFF),
      semanticLabel: "快进",
    ),
    this.fullscreenIcon = const Icon(
      Icons.fullscreen,
      size: 16,
      color: Color(0xFFFFFFFF),
      semanticLabel: "全屏",
    ),
    this.fullscreenExitIcon = const Icon(
      Icons.fullscreen_exit,
      size: 16,
      color: Color(0xFFFFFFFF),
      semanticLabel: "退出全屏",
    ),
    this.itemList = const [
      "rewind",
      "play",
      "forward",
      "progress",
      "time",
      "fullscreen"
    ],
  });

  final double height;
  final EdgeInsets padding;
  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final Color barBackgroundColor;
  final Widget playIcon;
  final Widget pauseIcon;
  final Widget rewindIcon;
  final Widget forwardIcon;
  final Widget fullscreenIcon;
  final Widget fullscreenExitIcon;
  final List<String> itemList;
}