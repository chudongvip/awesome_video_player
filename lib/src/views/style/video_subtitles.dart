import 'package:flutter/material.dart';

/// 字幕样式
class VideoSubtitles {
  VideoSubtitles({
    this.mainTitleFontSize = 14,
    this.mainTitleColor = const Color.fromRGBO(255, 255, 255, 1),
    this.subTitleFontSize = 12,
    this.subTitleColor = const Color.fromRGBO(255, 255, 255, 1),
    this.mianTitle,
    this.subTitle,
  });

  final double mainTitleFontSize;
  final Color mainTitleColor;
  final double subTitleFontSize;
  final Color subTitleColor;
  final Widget mianTitle; //主字幕
  final Widget subTitle; //副字幕
}
