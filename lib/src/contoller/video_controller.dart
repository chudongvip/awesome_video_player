import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AwesomeVideoValue {
  AwesomeVideoValue({
    this.aspectRatio,
    this.autoInitialize = false,
    this.autoPlay = false,
    this.startPosition,
    this.loop = false,
    this.allowScrubbing = true,
    this.fullScreenByDefault = false,
    this.showControlsOnInitialize = true,
    this.showControls = true,
    this.allowedScreenSleep = true,
    this.allowFullScreen = true,
    this.seekSeconds = 15,
    this.progressGestureUnit = 1,
    this.volumeGestureUnit = 0.05,
    this.brightnessGestureUnit = 0.05,
  });

  final double aspectRatio;

  final bool autoInitialize;

  final bool autoPlay;

  final Duration startPosition;

  final bool loop;

  final bool allowScrubbing;

  final bool fullScreenByDefault;

  final bool showControlsOnInitialize;

  final bool showControls;

  final bool allowedScreenSleep;

  final bool allowFullScreen;

  final num seekSeconds;

  final num progressGestureUnit;

  final double volumeGestureUnit;

  final double brightnessGestureUnit;
}

class AwesomeVideoController extends ChangeNotifier {
  VideoPlayerController videoPlayerController;

  AwesomeVideoController.network(this.dataSource,
      {this.options, this.formatHint, this.closedCaptionFile}) {
    this.options = this.options ?? AwesomeVideoValue();
    this.videoPlayerController = VideoPlayerController.network(this.dataSource,
        formatHint: this.formatHint, closedCaptionFile: this.closedCaptionFile);
    _initialize();
  }

  AwesomeVideoController.asset(this.dataSource,
      {this.options, this.package, this.closedCaptionFile}) {
    this.options = this.options ?? AwesomeVideoValue();
    this.videoPlayerController = VideoPlayerController.asset(this.dataSource,
        package: this.package, closedCaptionFile: this.closedCaptionFile);
    _initialize();
  }

  AwesomeVideoController.file(this.file,
      {this.options, this.closedCaptionFile}) {
    this.options = this.options ?? AwesomeVideoValue();
    this.videoPlayerController = VideoPlayerController.file(this.file,
        closedCaptionFile: this.closedCaptionFile);
    _initialize();
  }

  String dataSource;

  File file;

  AwesomeVideoValue options;

  dynamic package;

  VideoFormat formatHint;

  dynamic closedCaptionFile;

  bool _isFullScreen = false;

  bool get isFullScreen => _isFullScreen;

  bool get isPlaying => videoPlayerController.value.isPlaying;

  Future _initialize() async {
    await videoPlayerController.setLooping(this.options.loop);

    if ((this.options.autoInitialize || this.options.autoPlay) &&
        !videoPlayerController.value.initialized) {
      await videoPlayerController.initialize();
    }

    if (this.options.autoPlay) {
      if (this.options.fullScreenByDefault) {
        requestFullScreen();
      }

      await videoPlayerController.play();
    }

    if (this.options.startPosition != null) {
      await videoPlayerController.seekTo(this.options.startPosition);
    }

    if (this.options.fullScreenByDefault) {
      videoPlayerController.addListener(_fullScreenListener);
    }
  }

  void _fullScreenListener() async {
    if (videoPlayerController.value.isPlaying && !_isFullScreen) {
      requestFullScreen();
      videoPlayerController.removeListener(_fullScreenListener);
    }
  }

  void requestFullScreen() {
    _isFullScreen = true;
    notifyListeners();
  }

  void exitFullScreen() {
    _isFullScreen = false;
    notifyListeners();
  }

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }

  Future<void> setLooping(bool looping) async {
    await videoPlayerController.setLooping(looping);
  }

  Future<void> play() async {
    if (!videoPlayerController.value.initialized) {
      await videoPlayerController.initialize();
    }
    if (videoPlayerController.value.isPlaying) return;
    await videoPlayerController.play();
  }

  Future<void> pause() async {
    if (!videoPlayerController.value.isPlaying) return;
    await videoPlayerController.pause();
  }

  Future<void> togglePlay() async {
    if (!videoPlayerController.value.initialized ||
        !videoPlayerController.value.isPlaying) {
      await play();
    } else {
      await pause();
    }
  }

  Future<void> seekTo(Duration moment) async {
    await videoPlayerController.seekTo(moment);
  }

  Future<void> setVolume(double volume) async {
    await videoPlayerController.setVolume(volume);
  }

  void end() {
    videoPlayerController.value = VideoPlayerValue(duration: null);
    notifyListeners();
  }

  // void changeDataSource(dataSource) {
  //   if (dataSource is File) {
  //     if (this.file != dataSource) {
  //       videoPlayerController = AwesomeVideoController.file(this.file, options: this.options, closedCaptionFile: this.closedCaptionFile)
  //     }
  //   }
  // }
}
