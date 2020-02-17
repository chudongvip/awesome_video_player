/// 自定义播放参数
class VideoPlayOptions {
  VideoPlayOptions({
    this.aspectRatio = 16 / 9,
    this.startPosition = const Duration(seconds: 0),
    this.loop = false,
    this.seekSeconds = 15,
    this.autoplay = true,
    this.allowScrubbing = true,
  });

  /// 开始播放节点
  final Duration startPosition;

  /// 是否循环播放
  final bool loop;

  /// 视频快进秒数
  final num seekSeconds;

  /// 是否自动播放
  final bool autoplay;

  /// 视频播放比例
  final num aspectRatio;

  /// 是否运行进度条拖拽
  final bool allowScrubbing;
}
