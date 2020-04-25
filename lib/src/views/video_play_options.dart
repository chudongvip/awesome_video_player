/// 自定义播放参数
class VideoPlayOptions {
  VideoPlayOptions({
    this.aspectRatio = 16 / 9,
    this.startPosition = const Duration(seconds: 0),
    this.loop = false,
    this.seekSeconds = 15,
    this.progressGestureUnit = 1000,
    this.volumeGestureUnit = 0.01,
    this.brightnessGestureUnit = 0.01,
    this.autoplay = true,
    this.allowScrubbing = true,
  });

  /// 开始播放节点
  final Duration startPosition;

  /// 是否循环播放
  final bool loop;

  /// 视频快进秒数
  final num seekSeconds;

  /// 设置（横向）手势调节视频进度的秒数单位，默认为`1s`
  final num progressGestureUnit;

  /// 设置（右侧垂直）手势调节视频音量的单位，必须为0～1之间（不能小于0，不能大于1），默认为`0.01`
  final num volumeGestureUnit;

  /// 设置（左侧垂直）手势调节视频亮度的单位，必须为0～1之间（不能小于0，不能大于1），默认为`0.01`
  final num brightnessGestureUnit;

  /// 是否自动播放
  final bool autoplay;

  /// 视频播放比例
  final num aspectRatio;

  /// 是否运行进度条拖拽
  final bool allowScrubbing;
}
