import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';
import 'package:battery/battery.dart';
import 'package:video_player/video_player.dart';

import '../../../awesome_video_player.dart';
import '../controls/linear_progress_bar.dart';
import '../controls/default_progress_bar.dart';
import '../loading/video_loading_view.dart';

typedef VideoCallback<T> = void Function(T t);

class PlayerControls extends StatefulWidget {
  PlayerControls(
      {Key key,
      this.videoStyle,
      this.onpop,
      this.ontimeupdate,
      this.onended,
      this.onprogressdragStart,
      this.onprogressdragUpdate,
      this.onprogressdragEnd,
      this.children})
      : super(key: key);

  final VideoStyle videoStyle;
  final VideoCallback onpop;
  final VideoCallback ontimeupdate;
  final VideoCallback onended;
  final Function onprogressdragStart;
  final Function(Duration, Duration) onprogressdragUpdate;
  final Function onprogressdragEnd;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() {
    return _PlayerControlsState();
  }
}

class _PlayerControlsState extends State<PlayerControls>
    with SingleTickerProviderStateMixin {
  VideoPlayerValue _latestValue;
  VideoPlayerController controller;
  AwesomeVideoController awesomeController;

  AnimationController controlBarAnimationController;
  Animation<double> controlTopBarAnimation;
  Animation<double> controlBottomBarAnimation;

  /// 是否全屏
  bool fullscreened = false;
  // bool initialized = false;

  /// 屏幕亮度
  double brightness;
  int batteryLevel = 0;

  /// 是否显示控制拦
  bool _showMeau = false;
  get showMeau => _showMeau;
  set showMeau(value) {
    if (!_showMeau) {
      if (controlBarAnimationController != null) {
        _showMeau = value;
        controlBarAnimationController.forward();
      }
    } else {
      if (controlBarAnimationController != null) {
        _showMeau = value;
        controlBarAnimationController.reverse();
      }
    }
  }

  /// 是否正在缓冲
  bool checkBuffing = false;
  bool isBuffing = false;
  bool hideContolStuff = true;
  bool isEnded = false;
  bool showSliderToast = false;
  bool showTextToast = false;
  AlignmentGeometry toastPosition;
  String toastText = "";
  double toastVolumeValue;
  double toastBrightnessValue;

  String position = "--:--";
  String duration = "--:--";
  String networkType = "";
  Timer showTime;

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
      // if (showMeau) {
      //   controlBarAnimationController.forward();
      // } else {
      //   controlBarAnimationController.reverse();
      // }
    });
  }

  void createHideControlbarTimer() {
    clearHideControlbarTimer();

    ///如果是播放状态5秒后自动隐藏
    showTime = Timer(Duration(seconds: 5), () {
      if (controller != null && _latestValue.isPlaying) {
        if (showMeau) {
          setState(() {
            showMeau = false;
            // controlBarAnimationController.reverse();
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
    if (!showMeau) {
      setState(() {
        showMeau = true;
      });
      // toggleControls();
    } else {
      createHideControlbarTimer();
    }
  }

  void fastRewind(int seekSeconds) {
    var currentPosition = _latestValue.position;
    controller
        .seekTo(Duration(seconds: currentPosition.inSeconds - seekSeconds));
  }

  void fastForward(int seekSeconds) {
    var currentPosition = _latestValue.position;
    controller
        .seekTo(Duration(seconds: currentPosition.inSeconds + seekSeconds));
  }

  void toggleFullScreen() {
    awesomeController.toggleFullScreen();
  }

  //监听播放器状态变化
  void _handleVideoPlayerValue() {
    _latestValue = controller.value;
    if (_latestValue != null) {
      if (_latestValue.position != null && _latestValue.duration != null) {
        if (_latestValue.position >= _latestValue.duration) {
          isEnded = true;
          if (!showMeau) {
            showMeau = true;
            // controlBarAnimationController.forward();
          }
          position = "--:--";
          duration = "--:--";
          clearHideControlbarTimer();
          if (widget.onended != null) {
            widget.onended(_latestValue);
          }
        } else {
          var oPosition = _latestValue.position;
          var oDuration = _latestValue.duration;

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
          if (widget.ontimeupdate != null) {
            widget.ontimeupdate(_latestValue);
          }
          if (isEnded) {
            isEnded = false;
          }
        }
      }
    }
    setState(() {});
  }

  //初始化播放器
  Future<Null> initPlayer() async {
    controller.addListener(_handleVideoPlayerValue);

    _handleVideoPlayerValue();

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
                (fullscreened ? MediaQuery.of(context).padding.bottom : 0) +
                widget.videoStyle.videoControlBarStyle.margin.vertical * 2),
            end: 0.0 +
                (fullscreened ? MediaQuery.of(context).padding.bottom : 0))
        .animate(controlBarAnimationController);

    // network type
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      networkType = "4G";
    } else if (connectivityResult == ConnectivityResult.wifi) {
      networkType = "Wi-Fi";
    }

    Battery _battery = Battery();
    try {
      // Access current battery level
      batteryLevel = await _battery.batteryLevel;
    } catch (e) {
      print(
          "[Awesome Video Player] Access current battery level failure, Ignore this error if you are debug with android or iOS emulator.");
    }

    // Be informed when the state (full, charging, discharging) changes
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      // Do something with new state
      // print("BatteryState => $state");
      if (state == BatteryState.full) {
      } else if (state == BatteryState.charging) {
      } else if (state == BatteryState.discharging) {}
    });

    if (awesomeController.options.showControlsOnInitialize) {
      if (!showMeau) {
        setState(() {
          showMeau = true;
          // controlBarAnimationController.forward();
          if ((_latestValue != null && _latestValue.isPlaying) ||
              awesomeController.options.autoPlay) {
            createHideControlbarTimer();
          }
        });
      }
    }
  }

  void destoryPlayer() {
    controller.removeListener(_handleVideoPlayerValue);
    showTime?.cancel();
    clearHideControlbarTimer();
  }

  @override
  void didChangeDependencies() {
    final _oldController = awesomeController;
    awesomeController =
        ChangeNotifierProvider.of<AwesomeVideoController>(context);
    controller = awesomeController.videoPlayerController;

    if (_oldController != awesomeController) {
      destoryPlayer();
      initPlayer();
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    destoryPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return Center(
        child: Icon(
          Icons.error,
          color: Colors.white,
          size: 42,
        ),
      );
    }

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
                    if (!_latestValue.initialized) return;
                    togglePlay();
                  },

                  /// 水平滑动 - 调节视频进度
                  onHorizontalDragStart: (DragStartDetails details) {
                    if (!_latestValue.initialized) return;
                    setState(() {
                      showTextToast = true;
                      toastPosition = Alignment.center;
                    });
                    if (_latestValue.isPlaying) {
                      controller.pause();
                    }
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    if (!_latestValue.initialized) return;
                    if (!showMeau) {
                      setState(() {
                        showMeau = true;
                      });
                      createHideControlbarTimer();
                    }
                    //往右滑动
                    if (details.primaryDelta > 0) {
                      if (_latestValue.position >= _latestValue.duration) {
                        setState(() {
                          showTextToast = false;
                        });
                        return;
                      }
                      fastForward(
                          awesomeController.options.progressGestureUnit);
                    } else {
                      fastRewind(awesomeController.options.progressGestureUnit);
                    }
                    toastText = "$position / $duration";
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    setState(() {
                      showTextToast = false;
                      toastText = "";
                    });
                    if (!_latestValue.isPlaying) {
                      controller.play();
                    }
                  },

                  /// 垂直滑动 - 调节亮度以及音量
                  onVerticalDragStart: (DragStartDetails details) {
                    if (!_latestValue.initialized) return;
                    setState(() {
                      showSliderToast = true;
                    });
                  },
                  onVerticalDragUpdate: (DragUpdateDetails details) async {
                    if (!_latestValue.initialized) return;
                    // 右侧垂直滑动 - 音量调节
                    if (details.globalPosition.dx >=
                        (MediaQuery.of(context).size.width / 2)) {
                      double vol;
                      if (details.primaryDelta > 0) {
                        //往下滑动
                        if (_latestValue.volume <= 0) {
                          vol = 0;
                        } else {
                          vol = _latestValue.volume -
                                      awesomeController
                                          .options.volumeGestureUnit <=
                                  0
                              ? 0
                              : _latestValue.volume -
                                  awesomeController.options.volumeGestureUnit;
                        }
                        // if (widget.onvolume != null) {
                        //   widget.onvolume(vol);
                        // }
                      } else {
                        //往上滑动
                        if (_latestValue.volume >= 1) {
                          vol = 1;
                        } else {
                          vol = _latestValue.volume +
                              awesomeController.options.volumeGestureUnit;
                        }
                        // if (widget.onvolume != null) {
                        //   widget.onvolume(vol);
                        // }
                      }
                      controller.setVolume(vol);
                      toastPosition = Alignment.centerRight;
                      setState(() {
                        toastVolumeValue = vol;
                      });
                    } else {
                      // 左侧垂直滑动 - 亮度调节
                      if (brightness == null) {
                        brightness = await Screen.brightness;
                      }
                      if (details.primaryDelta > 0) {
                        //往下滑动
                        if (brightness <= 0) {
                          brightness = 0;
                        } else {
                          brightness = brightness -
                                      awesomeController
                                          .options.brightnessGestureUnit <=
                                  0
                              ? 0
                              : brightness -
                                  awesomeController
                                      .options.brightnessGestureUnit;
                        }
                        // if (widget.onbrightness != null) {
                        //   widget.onbrightness(brightness);
                        // }
                      } else {
                        //往上滑动
                        if (brightness >= 1) {
                          brightness = 1;
                        } else {
                          brightness +=
                              awesomeController.options.brightnessGestureUnit;
                        }
                        // if (widget.onbrightness != null) {
                        //   widget.onbrightness(brightness);
                        // }
                      }
                      setState(() {
                        toastPosition = Alignment.centerLeft;
                        toastBrightnessValue = brightness;
                      });
                      Screen.setBrightness(brightness);
                    }
                  },
                  onVerticalDragEnd: (DragEndDetails details) {
                    setState(() {
                      showSliderToast = false;
                      toastVolumeValue = null;
                      toastBrightnessValue = null;
                    });
                  },

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
          //
          _buildTopControlBar(controlTopBarAnimation, context),
          //
          _buildBottomControlBar(controlBottomBarAnimation, context),
          //
          _buildReplayBtn(context),
          //
          _buildToastView(context),
          //
          _buildLoadingView(context),
        ],
      ),
    );
  }

  //计算设备的宽高比
  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
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
                  //顶部状态栏
                  Positioned(
                    top: animation.value,
                    left: containerPadding,
                    right: containerPadding,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: widget.videoStyle.videoTopBarStyle.margin,
                      padding: widget.videoStyle.videoTopBarStyle.padding,
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
                          //顶部控制拦
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              /// 返回按钮
                              GestureDetector(
                                onTap: () {
                                  if (awesomeController.isFullScreen) {
                                    // Navigator.of(context, rootNavigator: true).pop();
                                    awesomeController.toggleFullScreen();
                                  } else {
                                    if (widget.onpop != null) {
                                      widget.onpop(null);
                                    }
                                  }
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

    Widget _buildRewindBtn() {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: () {
              fastRewind(awesomeController.options.seekSeconds);
            },
            child: widget.videoStyle.videoControlBarStyle.rewindIcon,
          ));
    }

    Widget _buildPlayOrPauseBtn() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
          onTap: () {
            if (isEnded) return;
            togglePlay();
          },
          child: _latestValue.isPlaying
              ? widget.videoStyle.videoControlBarStyle.pauseIcon
              : widget.videoStyle.videoControlBarStyle.playIcon,
        ),
      );
    }

    Widget _buildReplayBtn() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
            onTap: () {
              if (isEnded) {
                isEnded = false;
                controller.seekTo(Duration(seconds: 0));
              }
              createHideControlbarTimer();
              if (!_latestValue.isPlaying) {
                controller.play();
              }
            },
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.replay,
                  size: 16,
                  color: Colors.white,
                  semanticLabel: "开始播放",
                ),
                Text(
                  " replay",
                  style: TextStyle(color: Colors.white),
                )
              ],
            )),
      );
    }

    Widget _buildForwardBtn() {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: () {
              fastForward(awesomeController.options.seekSeconds);
            },
            child: widget.videoStyle.videoControlBarStyle.forwardIcon,
          ));
    }

    Widget _buildProgress() {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: VideoLinearProgressBar(controller,
              allowScrubbing: awesomeController.options.allowScrubbing,
              onprogressdragStart: () {
            setState(() {
              showTextToast = true;
            });
            if (_latestValue.isPlaying) {
              controller.pause();
            }
            if (widget.onprogressdragStart != null) {
              widget.onprogressdragStart();
            }
          }, onprogressdragUpdate: (Duration position, Duration duration) {
            if (widget.onprogressdragUpdate != null) {
              widget.onprogressdragUpdate(position, duration);
            }
          }, onprogressdragEnd: () {
            setState(() {
              showTextToast = false;
            });
            if (!_latestValue.isPlaying) {
              controller.play();
            }
            if (widget.onprogressdragEnd != null) {
              widget.onprogressdragEnd();
            }
          },
              padding:
                  widget.videoStyle.videoControlBarStyle.progressStyle.padding,
              progressStyle:
                  widget.videoStyle.videoControlBarStyle.progressStyle),
        ),
      );
    }

    Widget _buildBasicProgress() {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: VideoDefaultProgressBar(controller,
              allowScrubbing: awesomeController.options.allowScrubbing,
              // onprogressdrag: widget.onprogressdrag,
              progressStyle:
                  widget.videoStyle.videoControlBarStyle.progressStyle),
        ),
      );
    }

    Widget _buildTime() {
      return Padding(
        padding: widget.videoStyle.videoControlBarStyle.timePadding,
        child: Text(
          "$position / $duration",
          style: TextStyle(
            color: widget.videoStyle.videoControlBarStyle.timeFontColor,
            fontSize: widget.videoStyle.videoControlBarStyle.timeFontSize,
          ),
        ),
      );
    }

    Widget _buildPositionTime() {
      return Padding(
        padding: widget.videoStyle.videoControlBarStyle.timePadding,
        child: Text(
          "$position",
          style: TextStyle(
            color: widget.videoStyle.videoControlBarStyle.timeFontColor,
            fontSize: widget.videoStyle.videoControlBarStyle.timeFontSize,
          ),
        ),
      );
    }

    Widget _buildDurationTime() {
      return Padding(
        padding: widget.videoStyle.videoControlBarStyle.timePadding,
        child: Text(
          "$duration",
          style: TextStyle(
            color: widget.videoStyle.videoControlBarStyle.timeFontColor,
            fontSize: widget.videoStyle.videoControlBarStyle.timeFontSize,
          ),
        ),
      );
    }

    Widget _buildFullscreen() {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: toggleFullScreen,
            child: awesomeController.isFullScreen
                ? widget.videoStyle.videoControlBarStyle.fullscreenExitIcon
                : widget.videoStyle.videoControlBarStyle.fullscreenIcon,
          ));
    }

    /// 动态生成进度条组件
    List<Widget> generateVideoProgressChildren() {
      Map<String, Widget> videoProgressWidgets = {
        "rewind": _buildRewindBtn(),
        "play": _buildPlayOrPauseBtn(),
        "replay": _buildReplayBtn(),
        "forward": _buildForwardBtn(),

        ///线条视频进度条
        "progress": _buildProgress(),

        ///默认视频进度条
        "basic-progress": _buildBasicProgress(),
        "time": _buildTime(),
        "position-time": _buildPositionTime(),
        "duration-time": _buildDurationTime(),
        "fullscreen": _buildFullscreen(),
      };

      List<Widget> videoProgressChildrens = [];
      var userSpecifyItem = widget.videoStyle.videoControlBarStyle.itemList;
      // var userSpecifyItem = !isEnded ? widget.videoStyle.videoControlBarStyle.itemList : ["replay"];

      for (var i = 0; i < userSpecifyItem.length; i++) {
        videoProgressChildrens.add(videoProgressWidgets[userSpecifyItem[i]]);
      }

      return videoProgressChildrens;
      // return !isEnded ? videoProgressChildrens : [];
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
                          // mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: generateVideoProgressChildren(),
                        ),
                      ))
              : Container();
        });
  }

  Widget _buildReplayBtn(BuildContext context) {
    /// 是否显示重播按钮
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          if (isEnded) {
            isEnded = false;
            controller.seekTo(Duration(seconds: 0));
          }
          createHideControlbarTimer();
          if (!_latestValue.isPlaying) {
            controller.play();
          }
        },
        child: _latestValue != null && !_latestValue.isPlaying
            ? Container(
                // decoration: BoxDecoration(
                //   color: Theme.of(context).dialogBackgroundColor,
                //   borderRadius: BorderRadius.circular(48.0),
                // ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: isEnded
                      ? widget.videoStyle.replayIcon
                      : widget.videoStyle.showPlayIcon &&
                              !showTextToast &&
                              _latestValue.initialized
                          ? widget.videoStyle.playIcon
                          : Text(""),
                ),
              )
            : Text(""),
      ),
    );
  }

  Widget _buildToastView(BuildContext context) {
    if (showTextToast) {
      return Align(
        // alignment: toastPosition,
        alignment: Alignment.center,
        child: Padding(
          // padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width / 3),
          padding: EdgeInsets.all(0),
          child: Container(
            width: 150,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0x7f000000),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  toastText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (showSliderToast) {
      return Align(
        child: Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0x7f000000),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                toastBrightnessValue != null
                    ? Icons.brightness_high
                    : Icons.volume_up,
                color: Colors.white,
                size: 25,
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                    ((toastBrightnessValue != null
                                ? toastBrightnessValue
                                : toastVolumeValue != null
                                    ? toastVolumeValue
                                    : 0) *
                            100)
                        .clamp(0, 100)
                        .toStringAsFixed(0),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    )),
              ),
            ],
          ),
        ),
      );
    }

    return Align();
  }

  Widget _buildLoadingView(BuildContext context) {
    return _latestValue != null &&
                !_latestValue.isPlaying &&
                _latestValue.duration == null ||
            (!_latestValue.isPlaying && _latestValue.isBuffering)
        ? VideoLoadingView(loadingStyle: widget.videoStyle.videoLoadingStyle)
        : Text("");
  }
}
