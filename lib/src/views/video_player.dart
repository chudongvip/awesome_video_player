import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:orientation/orientation.dart';
import 'package:video_player/video_player.dart';
import 'package:screen/screen.dart';
// import 'package:connectivity/connectivity.dart';

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
  final VideoCallback<VideoPlayerValue> onpop;

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
    widget.controller.addListener(_listenerControllerChange);

    /// 控制拦动画
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

  void _listenerControllerChange() async {
    if (widget.controller.isFullScreen && !_isFullScreen) {
      _isFullScreen = true;
      await _pushFullScreenWidget(context);
    } else if (_isFullScreen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isFullScreen = false;
    }
  }

  /// 显示或隐藏菜单栏
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

      print(controlTopBarAnimation.value);
      print(showMeau);
    });
  }

  void createHideControlbarTimer() {
    clearHideControlbarTimer();

    ///如果是播放状态5秒后自动隐藏
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

  void clearHideControlbarTimer() {
    showTime?.cancel();
  }

  // Widget _fullScreenRoutePageBuilder(
  //     BuildContext context, Animation animation, Animation secondaryAnimation) {
  //   return AnimatedBuilder(
  //     animation: animation,
  //     builder: (BuildContext context, Widget child) {
  //       print("build 2");
  //       return Scaffold(
  //         resizeToAvoidBottomPadding: false,
  //         body: Container(
  //           alignment: Alignment.center,
  //           color: Colors.black,
  //           child: playerWithControls(context, widget.controller),
  //         ),
  //         floatingActionButton: FloatingActionButton(
  //           onPressed: () {
  //             widget.controller.exitFullScreen();
  //           },
  //           child: Icon(Icons.fullscreen_exit),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final TransitionRoute<Null> route = PageRouteBuilder<Null>(
      pageBuilder: _fullScreenRoutePageBuilder,
    );

    SystemChrome.setEnabledSystemUIOverlays([]);
    if (isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    // if (!widget.controller.allowedScreenSleep) {
    //   Wakelock.enable();
    // }

    //root根页面不能右滑退出页面
    await Navigator.of(context, rootNavigator: true).push(route);
    _isFullScreen = false;
    widget.controller.exitFullScreen();

    // The wakelock plugins checks whether it needs to perform an action internally,
    // so we do not need to check Wakelock.isEnabled.
    // Wakelock.disable();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  // List<Widget> buildControls() {

  //   /// 内置控件
  //   List<Widget> videoBuiltInChildrens() {

  //     return <Widget>[
  //       widget.controller.options.showControls
  //        ? Builder(
  //          builder: (context) {
  //            return VideoTopBar(
  //             // animation: controlTopBarAnimation,
  //             showControls: showMeau,
  //             videoTopBarStyle: widget.videoStyle.videoTopBarStyle,
  //             videoControlBarStyle: widget.videoStyle.videoControlBarStyle,
  //             onpop: () {
  //               if (_isFullScreen) {
  //                 widget.controller.toggleFullScreen();
  //                 // ChangeNotifierProvider.of<AwesomeVideoController>(context, listen: false).toggleFullScreen();
  //               } else {
  //                 if (widget.onpop != null) {
  //                   widget.onpop(null);
  //                 }
  //               }
  //             });
  //          },
  //        )
  //         : Align(),

  //       // VideoTopBar(
  //       //   animation: controlTopBarAnimation,
  //       // videoTopBarStyle: widget.videoStyle.videoTopBarStyle,
  //       // videoControlBarStyle: widget.videoStyle.videoControlBarStyle,
  //       // onpop: () {
  //       //   if (_isFullScreen) {
  //       //     widget.controller.toggleFullScreen();
  //       //     // ChangeNotifierProvider.of<AwesomeVideoController>(context).toggleFullScreen();
  //       //   } else {
  //       //     if (widget.onpop != null) {
  //       //       widget.onpop(null);
  //       //     }
  //       //   }
  //       // }),

  //     ];
  //   }

  //   List<Widget> videoChildrens = <Widget>[];

  //   ///手势容器
  //   Widget gestureContainer = Builder(builder: (context){
  //       return GestureDetector(
  //         //点击
  //         onTap: () {
  //           //显示或隐藏菜单栏和进度条
  //           toggleControls();
  //         },
  //         //双击
  //         onDoubleTap: () {
  //           if (!widget.videoPlayerController.value.initialized) return;
  //           ChangeNotifierProvider.of<AwesomeVideoController>(context, listen: false).togglePlay();
  //         },

  //         /// 水平滑动 - 调节视频进度
  //         onHorizontalDragStart: (DragStartDetails details) {
  //           if (!widget.videoPlayerController.value.initialized) return;
  //           if (widget.videoPlayerController.value.isPlaying) {
  //             ChangeNotifierProvider.of<AwesomeVideoController>(context, listen: false).pause();
  //           }
  //         },
  //         onHorizontalDragUpdate: (DragUpdateDetails details) {
  //           if (!widget.videoPlayerController.value.initialized) return;
  //           if (!showMeau) {
  //             setState(() {
  //               showMeau = true;
  //             });
  //             createHideControlbarTimer();
  //           }
  //           var currentPosition = widget.videoPlayerController.value.position;
  //           ChangeNotifierProvider.of<AwesomeVideoController>(context, listen: false).seekTo(Duration(
  //               milliseconds: details.primaryDelta > 0
  //                   ? currentPosition.inMilliseconds +
  //                       widget.controller.options.progressGestureUnit
  //                   : currentPosition.inMilliseconds -
  //                       widget.controller.options.progressGestureUnit));
  //         },
  //         onHorizontalDragEnd: (DragEndDetails details) {
  //           if (!widget.videoPlayerController.value.isPlaying) {
  //             ChangeNotifierProvider.of<AwesomeVideoController>(context, listen: false).play();
  //           }
  //         },

  //         /// 垂直滑动 - 调节亮度以及音量
  //         onVerticalDragStart: (DragStartDetails details) {
  //           if (!widget.videoPlayerController.value.initialized) return;
  //         },
  //         onVerticalDragUpdate: (DragUpdateDetails details) async {
  //           if (!widget.videoPlayerController.value.initialized) return;
  //           // 右侧垂直滑动 - 音量调节
  //           if (details.globalPosition.dx >= (MediaQuery.of(context).size.width / 2)) {
  //             if (details.primaryDelta > 0) {
  //               //往下滑动
  //               if (widget.videoPlayerController.value.volume <= 0) return;
  //               var vol = widget.videoPlayerController.value.volume -
  //                   widget.controller.options.volumeGestureUnit;
  //               // if (widget.onvolume != null) {
  //               //   widget.onvolume(vol);
  //               // }
  //               ChangeNotifierProvider.of<AwesomeVideoController>(context, listen: false).setVolume(vol);
  //             } else {
  //               //往上滑动
  //               if (widget.videoPlayerController.value.volume >= 1) return;
  //               var vol = widget.videoPlayerController.value.volume +
  //                   widget.controller.options.volumeGestureUnit;
  //               // if (widget.onvolume != null) {
  //               //   widget.onvolume(vol);
  //               // }
  //               ChangeNotifierProvider.of<AwesomeVideoController>(context, listen: false).setVolume(vol);
  //             }
  //           } else {
  //             // 左侧垂直滑动 - 亮度调节
  //             if (brightness == null) {
  //               brightness = await Screen.brightness;
  //             }
  //             if (details.primaryDelta > 0) {
  //               //往下滑动
  //               if (brightness <= 0) return;
  //               brightness -= widget.controller.options.brightnessGestureUnit;
  //               // if (widget.onbrightness != null) {
  //               //   widget.onbrightness(brightness);
  //               // }
  //             } else {
  //               //往上滑动
  //               if (brightness >= 1) return;
  //               brightness += widget.controller.options.brightnessGestureUnit;
  //               // if (widget.onbrightness != null) {
  //               //   widget.onbrightness(brightness);
  //               // }
  //             }
  //             Screen.setBrightness(brightness);
  //           }
  //         },
  //         onVerticalDragEnd: (DragEndDetails details) {},

  //       ///视频播放器
  //       child: AspectRatio(
  //       aspectRatio: widget.controller.options.aspectRatio ?? _calculateAspectRatio(context),
  //         child: Container(
  //           color: Colors.black,
  //           width: double.infinity,
  //           height: double.infinity,
  //           child: VideoPlayer(widget.videoPlayerController),
  //         ),
  //       ));
  //   });

  //   /// 内置手势及视频容器
  //   videoChildrens.add(gestureContainer);

  //   /// 内置组件
  //   videoChildrens.addAll(videoBuiltInChildrens());

  //   /// 自定义拓展元素
  //   videoChildrens.addAll(widget.children ?? []);

  //   return videoChildrens;
  // }

  // Widget playerWithControls(BuildContext context, AwesomeVideoController controller) {
  //   return ChangeNotifierProvider<AwesomeVideoController>(
  //     data: controller,
  //     child: Center(
  //       child: Container(
  //         width: MediaQuery.of(context).size.width,
  //         child: Stack(
  //           children: buildControls()
  //         ),
  //       ),
  //     )
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    print("build 1");
    // return playerWithControls(context, widget.controller);
    return ChangeNotifierProvider<AwesomeVideoController>(
        data: widget.controller,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: PlayerWithControls(
                videoStyle: widget.videoStyle, children: widget.children),
          ),
        ));
    // return ChangeNotifierProvider<AwesomeVideoController>(
    //   data: widget.controller,
    //   child: Center(
    //     child: Container(
    //       width: MediaQuery.of(context).size.width,
    //       child: Stack(
    //         children: buildControls()
    //       ),
    //     ),
    //   )
    // );
  }

  Widget _buildFullScreenVideo(BuildContext context,
      Animation<double> animation, ChangeNotifierProvider controllerProvider) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        color: Colors.black,
        child: controllerProvider,
      ),
    );
    // return Scaffold(
    //   resizeToAvoidBottomPadding: false,
    //   body: Container(
    //     alignment: Alignment.center,
    //     color: Colors.black,
    //     child: controllerProvider,
    //   ),
    // );
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
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: PlayerWithControls(
                videoStyle: widget.videoStyle, children: widget.children),
          ),
        ));

    return _defaultRoutePageBuilder(
        context, animation, secondaryAnimation, controllerProvider);
  }

  //计算设备的宽高比
  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
