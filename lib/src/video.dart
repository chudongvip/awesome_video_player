import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:orientation/orientation.dart';
import 'package:video_player/video_player.dart';
import 'package:screen/screen.dart';

import './video_style.dart';
import './video_play_options.dart';

import './video_progress_bar.dart';
import './video_progress_style.dart';

typedef VideoCallback<T> = void Function(T t);

/// 视频组件
class AwsomeVideoPlayer extends StatefulWidget {
  AwsomeVideoPlayer(
    this.dataSource, {
    Key key,
    VideoPlayOptions playOptions,
    VideoStyle videoStyle,
    this.children,
    this.onplay,
    this.onpause,
    this.ontimeupdate,
    this.onended,
    this.onpop,
  })  : playOptions = playOptions ?? VideoPlayOptions(),
        videoStyle = videoStyle ?? VideoStyle(),
        super(key: key);

  /// 视频资源
  final String dataSource;

  /// 播放自定义属性
  final VideoPlayOptions playOptions;
  final VideoStyle videoStyle;
  final List<Widget> children;

  /// 回调事件
  final VideoCallback<VideoPlayerValue> onplay; //播放开始回调
  final VideoCallback<VideoPlayerValue> ontimeupdate; //播放开始回调
  final VideoCallback<VideoPlayerValue> onpause; //播放暂停回调
  final VideoCallback<VideoPlayerValue> onended; //播放结束回调
  final VideoCallback<VideoPlayerValue> onpop; //顶部控制栏点击返回回调

  @override
  _AwsomeVideoPlayerState createState() => _AwsomeVideoPlayerState();
}

class _AwsomeVideoPlayerState extends State<AwsomeVideoPlayer> {
  /// 控制器 - 快进 seekTo 暂停 pause 播放 play 摧毁 dispose
  VideoPlayerController controller;

  /// 是否全屏
  bool fullscreened = false;

  /// 获取屏幕大小
  Size get screenSize => MediaQuery.of(context).size;

  bool initialized = false;
  bool showMeau = false;
  Timer showTime;
  String position = "--:--";
  String duration = "--:--";

  num progressTheme = 1;

  double brightness;

  void initPlayer() {
    if (controller == null) {
      if (widget.dataSource == null || widget.dataSource == "") return;
      controller = createVideoPlayerController()
        ..addListener(() {
          if (!mounted) {
            return;
          }
          if (controller != null) {
            if (controller.value.initialized) {
              var oPosition = controller.value.position;
              var oDuration = controller.value.duration;

              if (widget.ontimeupdate != null) {
                widget.ontimeupdate(controller.value);
              }

              if (controller.value.isPlaying) {
                setState(() {
                  position = oPosition.toString().split('.')[0];
                  duration = oDuration.toString().split('.')[0];
                });
              } else {
                if (oPosition >= oDuration) {
                  if (widget.onended != null) {
                    widget.onended(controller.value);
                  }
                }
              }
            }
          }
        })
        ..initialize().then((_) {
          print("初始化完成");
          initialized = true;
          setState(() {});
          if (widget.playOptions.autoplay) {
            if (widget.playOptions.startPosition.inSeconds != 0) {
              controller.seekTo(widget.playOptions.startPosition);
            }
            controller.play();
          }
        })
        ..setLooping(widget.playOptions.loop);
    }
  }

  @override
  void initState() {
    super.initState();

    brightness = 0.8;
    Screen.setBrightness(brightness);

    ///运行设备横竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 常亮
    Screen.keepOn(true);

    initPlayer();
  }

  @override
  void dispose() {
    clearHideControlbarTimer();
    controller.dispose();

    ///竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    Screen.keepOn(false);
    super.dispose();
  }

  //点击播放或暂停
  void togglePlay() {
    createHideControlbarTimer();

    if (controller.value.isPlaying) {
      controller.pause();
      if (widget.onpause != null) {
        widget.onpause(controller.value);
      }
    } else {
      controller.play();
      if (widget.onplay != null) {
        widget.onplay(controller.value);
      }
    }
    setState(() {});
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
    setState(() {});
  }

  void createHideControlbarTimer() {
    clearHideControlbarTimer();

    ///如果是播放状态5秒后自动隐藏
    showTime = Timer(Duration(milliseconds: 5000), () {
      if (controller.value.isPlaying) {
        if (showMeau) {
          setState(() {
            showMeau = false;
          });
        }
      }
    });
  }

  void clearHideControlbarTimer() {
    showTime?.cancel();
  }

  /// 视频快退
  void fastRewind() {
    createHideControlbarTimer();

    setState(() {
      print(controller.value.position);
      var currentPosition = controller.value.position;
      controller.seekTo(Duration(
          seconds: currentPosition.inSeconds - widget.playOptions.seekSeconds));
    });
  }

  /// 视频快进
  void fastForward() {
    createHideControlbarTimer();

    setState(() {
      var currentPosition = controller.value.position;
      controller.seekTo(Duration(
          seconds: currentPosition.inSeconds + widget.playOptions.seekSeconds));
    });
  }

  ///视频进度条
  Widget defaultVideoProgress() {
    if (progressTheme == 1) {
      return AwsomeVideoProgressIndicator(
        controller,
        progressStyle: AwsomeVideoProgressStyle()
      );
    } else {
      return VideoProgressIndicator(
        controller,
        allowScrubbing: widget.playOptions.allowScrubbing,
        colors: VideoProgressColors(
          playedColor: widget.videoStyle.videoControlBarStyle.playedColor,
          bufferedColor: widget.videoStyle.videoControlBarStyle.bufferedColor,
          backgroundColor: widget.videoStyle.videoControlBarStyle.backgroundColor,
        ),
        padding: EdgeInsets.all(0),
      );
    }
  }

  /// 动态生成进度条组件
  List<Widget> generateControlBarWidget() {
    Map<String, Widget> controlBarItems = {
      "rewind": GestureDetector(
        onTap: () {
          fastRewind();
        },
        child: widget.videoStyle.videoControlBarStyle.rewindIcon,
      ),
      "play": Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: () {
            togglePlay();
          },
          child: controller.value.isPlaying
              ? widget.videoStyle.videoControlBarStyle.pauseIcon
              : widget.videoStyle.videoControlBarStyle.playIcon,
        ),
      ),
      "forward": GestureDetector(
        onTap: () {
          fastForward();
        },
        child: widget.videoStyle.videoControlBarStyle.forwardIcon,
      ),
      "progress": Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: defaultVideoProgress(),
        ),
      ),
      "time": Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          "$position / $duration",
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
          ),
        ),
      ),
      "fullscreen": GestureDetector(
        onTap: () {
          OrientationPlugin.forceOrientation(!fullscreened
              ? DeviceOrientation.landscapeRight
              : DeviceOrientation.portraitUp);
          setState(() {
            fullscreened = !fullscreened;
          });
        },
        child: fullscreened
            ? widget.videoStyle.videoControlBarStyle.fullscreenExitIcon
            : widget.videoStyle.videoControlBarStyle.fullscreenIcon,
      ),
    };

    List<Widget> finalBuildItem = [];
    var userSpecifyItem = widget.videoStyle.videoControlBarStyle.itemList;

    for (var i = 0; i < userSpecifyItem.length; i++) {
      finalBuildItem.add(controlBarItems[userSpecifyItem[i]]);
    }

    return finalBuildItem;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      fullscreened = screenSize.width > screenSize.height;
    });

    if (!initialized) return _defaultFrame();

    // 初始化完成
    final children = _videoFrame();
    children.addAll(_controlFrame());
    children.addAll(widget.children ?? []);
    return AspectRatio(
      aspectRatio: fullscreened
          ? _calculateAspectRatio(context)
          : widget.playOptions.aspectRatio,
      child: Stack(children: children),
    );
  }

  Widget _defaultFrame() {
    return AspectRatio(
        aspectRatio: fullscreened
            ? _calculateAspectRatio(context)
            : widget.playOptions.aspectRatio,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ));
  }

  /// 播放器
  List<Widget> _videoFrame() {
    return [
      GestureDetector(
        onTap: () {
          //显示或隐藏菜单栏和进度条
          toggleControls();
        },
        //双击
        onDoubleTap: () {
          if (!controller.value.initialized) return;
          togglePlay();
        },
        /// 水平滑动
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
          var currentPosition = controller.value.position;
          controller.seekTo(Duration(
            milliseconds: details.primaryDelta > 0 ? currentPosition.inMilliseconds + 100 : currentPosition.inMilliseconds - 100 ));
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (!controller.value.isPlaying) {
            controller.play();
          }
        },
        /// 垂直滑动
        onVerticalDragStart: (DragStartDetails details) {
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          if (details.globalPosition.dx >= (screenSize.width/2)) {//右侧垂直滑动
            if (details.primaryDelta > 0) {//往下滑动
              if (controller.value.volume <= 0 ) return;
              controller.setVolume(controller.value.volume - 0.1);
            } else {//往上滑动
              if (controller.value.volume >= 1 ) return;
              controller.setVolume(controller.value.volume + 0.1);
            }
            print(controller.value.volume);
          } else {//左侧垂直滑动
            if (details.primaryDelta > 0) {//往下滑动
              if (brightness <= 0) return;
              brightness -= 0.1;
            } else {//往上滑动
              if (brightness >= 1) return;
              brightness += 0.1;  
            }
            print(brightness);
            Screen.setBrightness(brightness);
          }
        },
        onVerticalDragEnd: (DragEndDetails details) {
          // print("end === ");
          // print(details);
        },
        child: ClipRect(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
              )
            ),
          )
          
        )
      )
    ];
  }

  List<Widget> _controlFrame() {
    return [
      //
      widget.videoStyle.videoTopBarStyle.show && showMeau
          ? widget.videoStyle.videoTopBarStyle.customBar == null
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 30,
                    padding: widget.videoStyle.videoTopBarStyle.padding,
                    color: widget
                        .videoStyle.videoControlBarStyle.barBackgroundColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        /// 左侧控制栏
                        GestureDetector(
                          onTap: () {
                            if (widget.onpop != null) {
                              widget.onpop(null);
                            }
                          },
                          child: widget.videoStyle.videoTopBarStyle.popIcon,
                        ),

                        /// 中部控制栏
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:
                                widget.videoStyle.videoTopBarStyle.contents,
                          ),
                        ),

                        /// 右侧部控制栏
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: widget.videoStyle.videoTopBarStyle.actions,
                        )
                      ],
                    ),
                  ),
                )
              : widget.videoStyle.videoTopBarStyle.customBar
          : Align(),

      /// 是否显示播放按钮
      !controller.value.isPlaying && widget.videoStyle.showPlayIcon
          ? Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  if (!controller.value.isPlaying) {
                    togglePlay();
                  }
                },
                child: widget.videoStyle.playIcon,
              ),
            )
          : Text(""),

      /// 主字幕
      widget.videoStyle.videoSubtitlesStyle.mianTitle != null
          ? widget.videoStyle.videoSubtitlesStyle.mianTitle
          : Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
                child: Text("",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: widget
                            .videoStyle.videoSubtitlesStyle.mainTitleColor,
                        fontSize: widget
                            .videoStyle.videoSubtitlesStyle.mainTitleFontSize)),
              ),
            ),

      /// 辅字幕
      widget.videoStyle.videoSubtitlesStyle.subTitle != null
          ? widget.videoStyle.videoSubtitlesStyle.subTitle
          : Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text("",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            widget.videoStyle.videoSubtitlesStyle.subTitleColor,
                        fontSize: widget
                            .videoStyle.videoSubtitlesStyle.subTitleFontSize)),
              ),
            ),

      /// 进度条
      Align(
        alignment: Alignment.bottomCenter,
        child: showMeau
            ? Container(
                padding: widget.videoStyle.videoControlBarStyle.padding,
                height: widget.videoStyle.videoControlBarStyle.height,
                color:
                    widget.videoStyle.videoControlBarStyle.barBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: generateControlBarWidget(),
                ),
              )
            : Text(""),
      )
    ];
  }

  /// 创建video controller
  VideoPlayerController createVideoPlayerController() {
    final regx = new RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
    final isNetwork = regx.hasMatch(widget.dataSource);
    if (isNetwork)
      return VideoPlayerController.network(widget.dataSource);
    else
      return VideoPlayerController.asset(widget.dataSource);
  }

  double _calculateAspectRatio(BuildContext context) {
    final width = screenSize.width;
    final height = screenSize.height;

    // return widget.playOptions.aspectRatio ?? controller.value.aspectRatio;
    return width > height ? width / height : height / width;
  }
}
