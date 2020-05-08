import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../style/video_progress_style.dart';

typedef VideoProgressDragHandle = void Function(
    Duration position, Duration duration);

/// 自定义线性进度条
class VideoLinearProgressBar extends StatefulWidget {
  VideoLinearProgressBar(
    this.controller, {
    VideoProgressStyle progressStyle,
    this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
    this.onprogressdragStart,
    this.onprogressdragUpdate,
    this.onprogressdragEnd,
  }) : progressStyle = progressStyle ?? VideoProgressStyle();

  final VideoPlayerController controller;

  final VideoProgressStyle progressStyle;

  final bool allowScrubbing;

  final EdgeInsets padding;

  final Function onprogressdragStart;

  final VideoProgressDragHandle onprogressdragUpdate;

  final Function onprogressdragEnd;

  @override
  _VideoLinearProgressBarState createState() => _VideoLinearProgressBarState();
}

class _VideoLinearProgressBarState extends State<VideoLinearProgressBar> {
  _VideoLinearProgressBarState() {
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
      handleDragStart: widget.onprogressdragStart,
      handleDragUpdate: widget.onprogressdragUpdate,
      handleDragEnd: widget.onprogressdragEnd,
      allowScrubbing: widget.allowScrubbing,
      child: CustomPaint(
        painter: _ProgressBarPainter(controller.value, style),
        child: Container(),
      ),
    );
  }
}

/// 处理进度条手势
class _VideoScrubber extends StatefulWidget {
  _VideoScrubber(
      {@required this.child,
      @required this.controller,
      this.handleDragStart,
      this.handleDragUpdate,
      this.handleDragEnd,
      this.allowScrubbing});

  final Widget child;
  final VideoPlayerController controller;
  final bool allowScrubbing;
  final Function handleDragStart;
  final VideoProgressDragHandle handleDragUpdate;
  final Function handleDragEnd;

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

    void emitDragStart() {
      if (widget.handleDragStart != null) {
        widget.handleDragStart();
      }
    }

    void emitDragUpdate(globalPosition) {
      if (widget.handleDragUpdate != null) {
        final RenderBox box = context.findRenderObject();
        final Offset tapPos = box.globalToLocal(globalPosition);
        final double relative = tapPos.dx / box.size.width;
        final Duration position = controller.value.duration * relative;
        widget.handleDragUpdate(position, controller.value.duration);
      }
    }

    void emitDragEnd() {
      if (widget.handleDragUpdate != null) {
        widget.handleDragEnd();
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized || !widget.allowScrubbing) {
          return;
        }
        emitDragStart();
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized || !widget.allowScrubbing) {
          return;
        }
        emitDragUpdate(details.globalPosition);
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        emitDragEnd();
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
