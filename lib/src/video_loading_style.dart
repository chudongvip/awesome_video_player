import 'package:flutter/material.dart';

/// 字幕样式
class VideoLoadingStyle {
  VideoLoadingStyle({
    this.customLoadingIcon = const CircularProgressIndicator(strokeWidth: 2.0),
    this.customLoadingText,
    this.loadingText = "Loading...",
    this.loadingTextFontColor = Colors.white,
    this.loadingTextFontSize = 20,
  });

  final Widget customLoadingIcon;
  final Widget customLoadingText;
  final String loadingText;
  final Color loadingTextFontColor;
  final double loadingTextFontSize;
}
