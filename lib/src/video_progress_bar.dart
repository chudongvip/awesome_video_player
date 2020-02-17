import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import './video_progress_style.dart';

/// 处理进度条手势
class _VideoScrubber extends StatefulWidget {
  _VideoScrubber({
    @required this.child,
    @required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

/// 绘制进度条
class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value, this.style);

  final VideoPlayerValue value;
  final VideoProgressStyle style;

  //刷新布局的时候告诉flutter 是否需要重绘
  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  //绘制流程
  @override
  void paint(Canvas canvas, Size size) {
    final baseOffset = size.height / 2 - style.height / 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + style.height),
        ),
        Radius.circular(style.progressRadius),
      ),
      Paint()..color = style.backgroundColor,
    );
    if (!value.initialized) {
      return;
    }
    final double playedPartPercent =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * size.width;
      final double end = range.endFraction(value.duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, baseOffset),
            Offset(end, baseOffset + style.height),
          ),
          Radius.circular(style.progressRadius),
        ),
        Paint()..color = style.bufferedColor,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + style.height),
        ),
        Radius.circular(style.progressRadius),
      ),
      Paint()..color = style.playedColor,
    );

    final shadowPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(playedPart, baseOffset + style.height / 2),
          radius: style.dragHeight));

    canvas.drawShadow(shadowPath, Colors.black, 0.2, false);
    canvas.drawCircle(
      Offset(playedPart, baseOffset + style.height / 2),
      style.dragHeight,
      Paint()..color = style.dragBarColor,
    );
  }
}

/// 自定义视频进度条
class AwsomeVideoProgressIndicator extends StatefulWidget {
  AwsomeVideoProgressIndicator(
    this.controller, {
    VideoProgressStyle progressStyle,
    this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
  }) : progressStyle = progressStyle ?? VideoProgressStyle();

  final VideoPlayerController controller;

  final VideoProgressStyle progressStyle;

  final bool allowScrubbing;

  final EdgeInsets padding;

  @override
  _AwsomeVideoProgressIndicatorState createState() =>
      _AwsomeVideoProgressIndicatorState();
}

class _AwsomeVideoProgressIndicatorState
    extends State<AwsomeVideoProgressIndicator> {
  _AwsomeVideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressStyle get style => widget.progressStyle;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return _VideoScrubber(
      controller: controller,
      child: CustomPaint(
        painter: _ProgressBarPainter(controller.value, style),
        child: Container(),
      ),
    );
  }
}
