import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:battery/battery.dart';
import 'package:video_player/video_player.dart';

import '../../awesome_video_player.dart';
import './controls/default_progress_bar.dart';
import './controls/linear_progress_bar.dart';
import './style/video_style.dart';

class PlayerWithControls extends StatefulWidget {
  PlayerWithControls({Key key, this.videoStyle, this.children})
      : super(key: key);

  final VideoStyle videoStyle;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() {
    return _PlayerWithControlsState();
  }
}

class _PlayerWithControlsState extends State<PlayerWithControls>
    with SingleTickerProviderStateMixin {
  VideoPlayerController controller;
  AwesomeVideoController awesomeController;
  VideoPlayerValue latestPlayerValue;

  AnimationController controlBarAnimationController;
  Animation<double> controlTopBarAnimation;
  Animation<double> controlBottomBarAnimation;

  /// 是否全屏
  bool fullscreened = false;
  bool initialized = false;

  /// 屏幕亮度
  double brightness;
  int batteryLevel;

  /// 是否显示控制拦
  bool showMeau = false;

  /// 是否正在缓冲
  bool checkBuffing = false;
  bool isBuffing = false;
  bool hideContolStuff = true;

  String position = "--:--";
  String duration = "--:--";
  String networkType = "";
  Timer showTime;

  StreamSubscription<ConnectivityResult> subscription;

  //计算设备的宽高比
  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
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
    });
  }

  void createHideControlbarTimer() {
    clearHideControlbarTimer();

    ///如果是播放状态5秒后自动隐藏
    showTime = Timer(Duration(milliseconds: 5000), () {
      if (controller != null && controller.value.isPlaying) {
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

  void togglePlay() {
    awesomeController.togglePlay();
  }

  void fastRewind(int seekSeconds) {
    var currentPosition = controller.value.position;
    controller
        .seekTo(Duration(seconds: currentPosition.inSeconds - seekSeconds));
  }

  void fastForward(int seekSeconds) {
    var currentPosition = controller.value.position;
    controller
        .seekTo(Duration(seconds: currentPosition.inSeconds + seekSeconds));
  }

  void toggleFullScreen() {
    awesomeController.toggleFullScreen();
  }

  //初始化播放器
  Future<Null> initPlyaer() async {
    controller.addListener(_handleVideoPlayerValue);

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

    // Instantiate it
    var battery = Battery();

    // Access current battery level
    batteryLevel = await battery.batteryLevel;

    // Be informed when the state (full, charging, discharging) changes
    // _battery.onBatteryStateChanged.listen((BatteryState state) {
    //   // Do something with new state
    //   print("BatteryState => $state");
    // });

    /// 网络监听
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!
      networkType = result.toString().split('.')[1];
      // if (widget.onnetwork != null) {
      //   widget.onnetwork(result.toString().split('.')[1]);
      // }
    });

    // _handleVideoPlayerValue();

    // if ((controller.value != null && controller.value.isPlaying) ||
    //     awesomeController.autoPlay) {
    //   _startHideTimer();
    // }

    // if (awesomeController.showControlsOnInitialize) {
    //   _initTimer = Timer(Duration(milliseconds: 200), () {
    //     setState(() {
    //       hideContolStuff = false;
    //     });
    //   });
    // }
  }

  //监听播放器状态变化
  void _handleVideoPlayerValue() {
    if (!mounted) {
      return;
    }
    if (controller != null) {
      if (controller.value.initialized) {
        var oPosition = controller.value.position;
        var oDuration = controller.value.duration;

        // if (widget.ontimeupdate != null) {
        //   widget.ontimeupdate(controller.value);
        // }

        if (controller.value.buffered.length == 0) {
          setState(() {
            checkBuffing = true;
          });
        }
        if (checkBuffing) {
          setState(() {
            isBuffing = controller.value.isBuffering;
            if (!isBuffing) {
              checkBuffing = false;
            }
          });
        }

        //添加一个错误提示builder
        // print("error: " + controller.value.errorDescription);

        if (controller.value.isPlaying) {
          setState(() {
            if (oDuration.inHours == 0) {
              var strPosition = oPosition.toString().split('.')[0];
              var strDuration = oDuration.toString().split('.')[0];
              position =
                  "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
              duration =
                  "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
            } else {
              position = oPosition.toString().split('.')[0];
              duration = oDuration.toString().split('.')[0];
            }
          });
        } else {
          if (oPosition >= oDuration) {
            // if (widget.onended != null) {
            //   resetVideoPlayer();
            //   widget.onended(controller.value);
            // }
          }
        }
      }

      setState(() {
        latestPlayerValue = controller.value;
      });
    }
  }

  void destoryPlayer() {
    controller.removeListener(_handleVideoPlayerValue);
    // _hideTimer?.cancel();
    // _initTimer?.cancel();
    // _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = awesomeController;
    awesomeController =
        ChangeNotifierProvider.of<AwesomeVideoController>(context);
    controller = awesomeController.videoPlayerController;

    if (_oldController != awesomeController) {
      destoryPlayer();
      initPlyaer();
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    destoryPlayer();
    super.dispose();
  }

  //顶部状态栏和顶部控制拦
  AnimatedBuilder _buildTopControlBar(
    Animation animation,
    BuildContext context,
  ) {
    double containerPadding = 0;
    double width = MediaQuery.of(context).size.width;

    if (awesomeController.isFullScreen && width > 414) {
      width = width - width * 0.8;
      containerPadding = width / 2;
    }
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return awesomeController.options.showControls
              ? widget.videoStyle.videoTopBarStyle.customBar ??
                  Positioned(
                    top: animation.value,
                    left: containerPadding,
                    right: containerPadding,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: widget.videoStyle.videoTopBarStyle.margin,
                      padding: widget.videoStyle.videoTopBarStyle.padding,
                      // height: widget.videoStyle.videoTopBarStyle.height,
                      // decoration: BoxDecoration(color: Colors.red),
                      // decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //   colors: [
                      //     videoControlBarStyle.barBackgroundColor,
                      //     Colors.transparent
                      //   ],
                      //   begin: Alignment.topCenter,
                      //   end: Alignment.bottomCenter,
                      // )),
                      child: Column(
                        children: <Widget>[
                          awesomeController.isFullScreen
                              ? Row(
                                  children: <Widget>[
                                    Text(networkType,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                            DateTime.now()
                                                .toString()
                                                .split(" ")[1]
                                                .substring(0, 5),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ),
                                    ),
                                    Row(children: <Widget>[
                                      Text(batteryLevel.toString() + "%",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      Icon(
                                        // Icons.battery_alert,
                                        // Icons.battery_charging_full,
                                        // Icons.battery_full,
                                        Icons.battery_std,
                                        // Icons.battery_unknown,
                                        size: 16,
                                        color: Color(0xFFFFFFFF),
                                        semanticLabel: "电池",
                                      )
                                    ]),
                                  ],
                                )
                              : Container(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              /// 返回按钮
                              GestureDetector(
                                onTap: () {
                                  if (awesomeController.isFullScreen) {
                                    awesomeController.toggleFullScreen();
                                  }
                                  // if (onpop != null) {
                                  //   onpop();
                                  // }
                                },
                                child:
                                    widget.videoStyle.videoTopBarStyle.popIcon,
                              ),

                              /// 中部控制栏
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: widget
                                      .videoStyle.videoTopBarStyle.contents,
                                ),
                              ),

                              /// 右侧部控制栏
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children:
                                    widget.videoStyle.videoTopBarStyle.actions,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
              : Container();
        });
  }

  //底部控制拦
  AnimatedBuilder _buildBottomControlBar(
    Animation animation,
    BuildContext context,
  ) {
    double containerPadding = 0;
    double width = MediaQuery.of(context).size.width;

    if (awesomeController.isFullScreen && width > 414) {
      width = width - width * 0.8;
      containerPadding = width / 2;
    }

    /// 动态生成进度条组件
    List<Widget> generateVideoProgressChildren() {
      Map<String, Widget> videoProgressWidgets = {
        "rewind": Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                fastRewind(awesomeController.options.seekSeconds);
              },
              child: widget.videoStyle.videoControlBarStyle.rewindIcon,
            )),
        "play": Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: () {
              togglePlay();
            },
            child: awesomeController.isPlaying
                ? widget.videoStyle.videoControlBarStyle.pauseIcon
                : widget.videoStyle.videoControlBarStyle.playIcon,
          ),
        ),
        "forward": Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                fastForward(awesomeController.options.seekSeconds);
              },
              child: widget.videoStyle.videoControlBarStyle.forwardIcon,
            )),

        ///线条视频进度条
        "progress": Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: VideoLinearProgressBar(controller,
                allowScrubbing: awesomeController.options.allowScrubbing,
                // onprogressdrag: widget.onprogressdrag,
                padding: widget
                    .videoStyle.videoControlBarStyle.progressStyle.padding,
                progressStyle:
                    widget.videoStyle.videoControlBarStyle.progressStyle),
          ),
        ),

        ///默认视频进度条
        "basic-progress": Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: VideoDefaultProgressBar(controller,
                allowScrubbing: awesomeController.options.allowScrubbing,
                // onprogressdrag: widget.onprogressdrag,
                progressStyle:
                    widget.videoStyle.videoControlBarStyle.progressStyle),
          ),
        ),

        "time": Padding(
          padding: widget.videoStyle.videoControlBarStyle.timePadding,
          child: Text(
            "$position / $duration",
            style: TextStyle(
              color: widget.videoStyle.videoControlBarStyle.timeFontColor,
              fontSize: widget.videoStyle.videoControlBarStyle.timeFontSize,
            ),
          ),
        ),
        "position-time": Padding(
          padding: widget.videoStyle.videoControlBarStyle.timePadding,
          child: Text(
            "$position",
            style: TextStyle(
              color: widget.videoStyle.videoControlBarStyle.timeFontColor,
              fontSize: widget.videoStyle.videoControlBarStyle.timeFontSize,
            ),
          ),
        ),
        "duration-time": Padding(
          padding: widget.videoStyle.videoControlBarStyle.timePadding,
          child: Text(
            "$duration",
            style: TextStyle(
              color: widget.videoStyle.videoControlBarStyle.timeFontColor,
              fontSize: widget.videoStyle.videoControlBarStyle.timeFontSize,
            ),
          ),
        ),
        "fullscreen": Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: toggleFullScreen,
              child: awesomeController.isFullScreen
                  ? widget.videoStyle.videoControlBarStyle.fullscreenExitIcon
                  : widget.videoStyle.videoControlBarStyle.fullscreenIcon,
            )),
      };

      List<Widget> videoProgressChildrens = [];
      var userSpecifyItem = widget.videoStyle.videoControlBarStyle.itemList;

      for (var i = 0; i < userSpecifyItem.length; i++) {
        videoProgressChildrens.add(videoProgressWidgets[userSpecifyItem[i]]);
      }

      return videoProgressChildrens;
    }

    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return awesomeController.options.showControls
              ? widget.videoStyle.videoTopBarStyle.customBar ??
                  Positioned(
                      bottom: animation.value,
                      left: containerPadding,
                      right: containerPadding,
                      child: Container(
                        margin: widget.videoStyle.videoControlBarStyle.margin,
                        padding: widget.videoStyle.videoControlBarStyle.padding,
                        height: widget.videoStyle.videoControlBarStyle.height,
                        // decoration: BoxDecoration(
                        //     gradient: LinearGradient(
                        //   colors: [Colors.transparent, videoControlBarStyle.barBackgroundColor],
                        //   begin: Alignment.topCenter,
                        //   end: Alignment.bottomCenter,
                        // )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: generateVideoProgressChildren(),
                        ),
                      ))
              : Container();
        });
  }

  //
  Container _buildPlayerWithControls(
      AwesomeVideoController awesomeController, BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: containerPadding),
      child: Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: awesomeController.options.aspectRatio ??
                  _calculateAspectRatio(context),
              // child: VideoPlayer(awesomeController.videoPlayerController),
              child: GestureDetector(
                  //点击
                  onTap: () {
                    //显示或隐藏菜单栏和进度条
                    toggleControls();
                  },
                  //双击
                  onDoubleTap: () {
                    if (!controller.value.initialized) return;
                    togglePlay();
                  },

                  /// 水平滑动 - 调节视频进度
                  onHorizontalDragStart: (DragStartDetails details) {
                    if (!controller.value.initialized) return;
                    if (controller.value.isPlaying) {
                      controller.pause();
                    }
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    if (!controller.value.initialized) return;
                    if (!showMeau) {
                      setState(() {
                        showMeau = true;
                      });
                      createHideControlbarTimer();
                    }
                    //往右滑动
                    if (details.primaryDelta > 0) {
                      fastForward(
                          awesomeController.options.progressGestureUnit);
                    } else {
                      fastRewind(awesomeController.options.progressGestureUnit);
                    }
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    if (!controller.value.isPlaying) {
                      controller.play();
                    }
                  },

                  /// 垂直滑动 - 调节亮度以及音量
                  onVerticalDragStart: (DragStartDetails details) {
                    if (!controller.value.initialized) return;
                  },
                  onVerticalDragUpdate: (DragUpdateDetails details) async {
                    if (!controller.value.initialized) return;
                    // 右侧垂直滑动 - 音量调节
                    if (details.globalPosition.dx >=
                        (MediaQuery.of(context).size.width / 2)) {
                      if (details.primaryDelta > 0) {
                        //往下滑动
                        if (controller.value.volume <= 0) return;
                        var vol = controller.value.volume -
                            awesomeController.options.volumeGestureUnit;
                        // if (widget.onvolume != null) {
                        //   widget.onvolume(vol);
                        // }
                        controller.setVolume(vol);
                      } else {
                        //往上滑动
                        if (controller.value.volume >= 1) return;
                        var vol = controller.value.volume +
                            awesomeController.options.volumeGestureUnit;
                        // if (widget.onvolume != null) {
                        //   widget.onvolume(vol);
                        // }
                        controller.setVolume(vol);
                      }
                    } else {
                      // 左侧垂直滑动 - 亮度调节
                      if (brightness == null) {
                        brightness = await Screen.brightness;
                      }
                      if (details.primaryDelta > 0) {
                        //往下滑动
                        if (brightness <= 0) return;
                        brightness -=
                            awesomeController.options.brightnessGestureUnit;
                        // if (widget.onbrightness != null) {
                        //   widget.onbrightness(brightness);
                        // }
                      } else {
                        //往上滑动
                        if (brightness >= 1) return;
                        brightness +=
                            awesomeController.options.brightnessGestureUnit;
                        // if (widget.onbrightness != null) {
                        //   widget.onbrightness(brightness);
                        // }
                      }
                      Screen.setBrightness(brightness);
                    }
                  },
                  onVerticalDragEnd: (DragEndDetails details) {},

                  ///视频播放器
                  child: ClipRect(
                      child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: Center(
                        child: AspectRatio(
                      aspectRatio: awesomeController.options.aspectRatio ??
                          _calculateAspectRatio(context),
                      child: VideoPlayer(controller),
                    )),
                  ))),
            ),
          ),
          //封面
          // awesomeController.overlay ?? Container(),
          //构建播放器的控件
          _buildTopControlBar(controlTopBarAnimation, context),
          _buildBottomControlBar(controlBottomBarAnimation, context),
          // _buildControls(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: awesomeController.options.aspectRatio ??
              _calculateAspectRatio(context),
          child: _buildPlayerWithControls(awesomeController, context),
        ),
      ),
    );
  }
}
