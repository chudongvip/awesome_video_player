import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:screen/screen.dart';

import './style/video_style.dart';

//widgets
import '../views/player_with_controls.dart';

//
import '../contoller/video_controller.dart';
import '../model/changenotify_provider.dart';

typedef VideoCallback<T> = void Function(T t);

class AwesomeVideoPlayer extends StatefulWidget {
  AwesomeVideoPlayer({
    Key key,
    this.controller,
    this.children,
    this.onpop,
    this.ontimeupdate,
    this.onended,
    this.onprogressdragStart,
    this.onprogressdragUpdate,
    this.onprogressdragEnd,
    VideoStyle videoStyle,
  })  : videoPlayerController = controller.videoPlayerController ?? null,
        videoStyle = videoStyle ?? VideoStyle(),
        super(key: key);

  /// 播放自定义属性
  final VideoStyle videoStyle;

  final List<Widget> children;

  final AwesomeVideoController controller;

  final VideoPlayerController videoPlayerController;

  //顶部控制栏点击返回回调
  final VideoCallback<Null> onpop;

  final VideoCallback<VideoPlayerValue> ontimeupdate;

  final VideoCallback<VideoPlayerValue> onended;

  final Function onprogressdragStart;

  final Function(Duration position, Duration duration) onprogressdragUpdate;

  final Function onprogressdragEnd;

  @override
  _AwesomeVideoPlayerState createState() => _AwesomeVideoPlayerState();
}

class _AwesomeVideoPlayerState extends State<AwesomeVideoPlayer>
    with SingleTickerProviderStateMixin {
  AnimationController controlBarAnimationController;
  Animation<double> controlTopBarAnimation;
  Animation<double> controlBottomBarAnimation;

  bool _isFullScreen = false;

  /// 屏幕亮度
  double brightness;

  /// 是否显示控制拦
  bool showMeau = false;

  /// flag
  Timer showTime;

  @override
  void initState() {
    super.initState();

    print("object => ");

    //listen AwesomeVideoValue change
    widget.controller.addListener(_listenerControllerChange);

    /// init animation controller
    controlBarAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    controlTopBarAnimation = Tween(
            begin: -(widget.videoStyle.videoTopBarStyle.height +
                widget.videoStyle.videoTopBarStyle.margin.vertical * 2),
            end: 0.0)
        .animate(controlBarAnimationController);
    controlBottomBarAnimation = Tween(
            begin: -(widget.videoStyle.videoTopBarStyle.height +
                widget.videoStyle.videoControlBarStyle.margin.vertical * 2),
            end: 0.0)
        .animate(controlBarAnimationController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listenerControllerChange);
    clearHideControlbarTimer();
    super.dispose();
  }

  @override
  void didUpdateWidget(AwesomeVideoPlayer oldWidget) {
    print("didUpdateWidget");
    if (oldWidget.controller != widget.controller) {
      widget.controller.addListener(_listenerControllerChange);
    }
    super.didUpdateWidget(oldWidget);
  }

  // AwesomeVideoValue linstener
  void _listenerControllerChange() async {
    if (widget.controller.isFullScreen && !_isFullScreen) {
      _isFullScreen = true;
      await _pushFullScreenWidget(context);
    } else if (_isFullScreen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isFullScreen = false;
    }
  }

  /// show or hide video controls
  void toggleControls() {
    clearHideControlbarTimer();

    if (!showMeau) {
      showMeau = true;
      createHideControlbarTimer();
    } else {
      showMeau = false;
    }
    setState(() {
      if (showMeau) {
        controlBarAnimationController.forward();
      } else {
        controlBarAnimationController.reverse();
      }
    });
  }

  // reset the timer
  void createHideControlbarTimer() {
    clearHideControlbarTimer();

    //hide controls after 5 seconds
    showTime = Timer(Duration(milliseconds: 5000), () {
      if (widget.videoPlayerController != null &&
          widget.videoPlayerController.value.isPlaying) {
        if (showMeau) {
          setState(() {
            showMeau = false;
            controlBarAnimationController.reverse();
          });
        }
      }
    });
  }

  //clear the timer
  void clearHideControlbarTimer() {
    showTime?.cancel();
  }

  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final TransitionRoute<Null> route = PageRouteBuilder<Null>(
      pageBuilder: _fullScreenRoutePageBuilder,
    );

    SystemChrome.setEnabledSystemUIOverlays([]);
    // if (isAndroid) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // }

    if (!widget.controller.options.allowedScreenSleep) {
      Screen.keepOn(true);
    }

    //root根页面不能右滑退出页面
    await Navigator.of(context, rootNavigator: true).push(route);
    _isFullScreen = false;
    widget.controller.exitFullScreen();

    Screen.keepOn(false);

    SystemChrome.setEnabledSystemUIOverlays(
        widget.controller.options.systemOverlaysAfterFullScreen);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setPreferredOrientations(
        widget.controller.options.deviceOrientationsAfterFullScreen);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AwesomeVideoController>(
        data: widget.controller,
        child: PlayerWithControls(
            videoStyle: widget.videoStyle,
            onpop: widget.onpop,
            ontimeupdate: widget.ontimeupdate,
            onended: widget.onended,
            onprogressdragStart: widget.onprogressdragStart,
            onprogressdragUpdate: widget.onprogressdragUpdate,
            onprogressdragEnd: widget.onprogressdragEnd,
            children: widget.children));
  }

  Widget _buildFullScreenVideo(BuildContext context,
      Animation<double> animation, ChangeNotifierProvider controllerProvider) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        alignment: Alignment.center,
        color: Colors.black,
        child: controllerProvider,
      ),
    );
  }

  AnimatedWidget _defaultRoutePageBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ChangeNotifierProvider controllerProvider) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return _buildFullScreenVideo(context, animation, controllerProvider);
      },
    );
  }

  Widget _fullScreenRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    var controllerProvider = ChangeNotifierProvider<AwesomeVideoController>(
      data: widget.controller,
      child: PlayerWithControls(
          videoStyle: widget.videoStyle,
          onpop: widget.onpop,
          ontimeupdate: widget.ontimeupdate,
          onended: widget.onended,
          onprogressdragStart: widget.onprogressdragStart,
          onprogressdragUpdate: widget.onprogressdragUpdate,
          onprogressdragEnd: widget.onprogressdragEnd,
          children: widget.children),
    );

    return _defaultRoutePageBuilder(
        context, animation, secondaryAnimation, controllerProvider);
  }
}
