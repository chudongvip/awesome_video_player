import 'package:flutter/material.dart';
import './video_top_bar_style.dart';
import './video_control_bar_style.dart';
import './video_subtitles.dart';
import './video_loading_style.dart';

/// 播放器样式
class VideoStyle {
  VideoStyle({
    VideoTopBarStyle videoTopBarStyle,
    VideoControlBarStyle videoControlBarStyle,
    VideoSubtitles videoSubtitlesStyle,
    VideoLoadingStyle videoLoadingStyle,
    // this.videoCover = "",
    this.playIcon = const Icon(
      Icons.play_circle_outline,
      color: Color(0xFFA4A3A3),
      size: 80,
      semanticLabel: "开始播放",
    ),
    this.showPlayIcon = true,
  })  : videoTopBarStyle = videoTopBarStyle ?? VideoTopBarStyle(),
        videoControlBarStyle = videoControlBarStyle ?? VideoControlBarStyle(),
        videoSubtitlesStyle = videoSubtitlesStyle ?? VideoSubtitles(),
        videoLoadingStyle = videoLoadingStyle ?? VideoLoadingStyle();

  final VideoTopBarStyle videoTopBarStyle; //视频顶部样式
  final VideoControlBarStyle videoControlBarStyle; //进度条样式
  final VideoSubtitles videoSubtitlesStyle; //字幕样式
  final VideoLoadingStyle videoLoadingStyle; //loading样式
  // final String videoCover; //视频封面
  final Widget playIcon; //暂停时显示
  final bool showPlayIcon; //暂停时是否显示播放按钮
}
