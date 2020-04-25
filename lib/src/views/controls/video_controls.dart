import 'package:awesome_video_player/src/views/controls/default_progress_bar.dart';
import 'package:awesome_video_player/src/views/controls/linear_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

import '../../../awesome_video_player.dart';
import '../style/video_top_bar_style.dart';
import '../style/video_control_bar_style.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls(
      {Key key,
      this.controller,
      this.awesomeController,
      this.videoTopBarStyle,
      this.videoControlBarStyle,
      this.children})
      : super(key: key);

  final VideoTopBarStyle videoTopBarStyle;
  final VideoControlBarStyle videoControlBarStyle;
  final VideoPlayerController controller;
  final AwesomeVideoController awesomeController;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() {
    return _PlayerControlsState();
  }
}

class _PlayerControlsState extends State<PlayerControls> {
  bool hideContolStuff = false;
  String position = "--:--";
  String duration = "--:--";

  AnimatedAlign _buildTopControlBar(
    BuildContext context,
  ) {
    return AnimatedAlign(
      curve: Curves.bounceInOut,
      alignment: Alignment(0, 0),
      duration: Duration(milliseconds: 300),
      child: widget.awesomeController.options.showControls
          ? widget.videoTopBarStyle.customBar ??
              Container(
                alignment: Alignment.center,
                // width: awesomeController.isFullScreen ? 480 : double.infinity,
                width: 480,
                margin: widget.videoTopBarStyle.margin,
                padding: widget.videoTopBarStyle.padding,
                height: widget.videoTopBarStyle.height,
                // decoration: BoxDecoration(color: Colors.red),
                // decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //   colors: [
                //     widget.videoControlBarStyle.barBackgroundColor,
                //     Colors.transparent
                //   ],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // )),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    /// 返回按钮
                    GestureDetector(
                      onTap: () {
                        if (widget.awesomeController.isFullScreen) {
                          widget.awesomeController.toggleFullScreen();
                        }
                        // if (widget.onpop != null) {
                        //   widget.onpop();
                        // }
                      },
                      child: widget.videoTopBarStyle.popIcon,
                    ),

                    /// 中部控制栏
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: widget.videoTopBarStyle.contents,
                      ),
                    ),

                    /// 右侧部控制栏
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: widget.videoTopBarStyle.actions,
                    )
                  ],
                ),
              )
          : Container(),
    );
  }

  AnimatedAlign _buildBottomControlBar(
    VideoControlBarStyle videoControlBarStyle,
    BuildContext context,
  ) {
    /// 动态生成进度条组件
    List<Widget> generateVideoProgressChildren() {
      void fastRewind() {
        var currentPosition = widget.controller.value.position;
        widget.controller.seekTo(Duration(
            seconds: currentPosition.inSeconds -
                widget.awesomeController.options.seekSeconds));
      }

      void togglePlay() {
        // awesomeController.togglePlay();
        setState(() {
          hideContolStuff = !hideContolStuff;
        });
      }

      void fastForward() {
        var currentPosition = widget.controller.value.position;
        widget.controller.seekTo(Duration(
            seconds: currentPosition.inSeconds +
                widget.awesomeController.options.seekSeconds));
      }

      void toggleFullScreen() {
        widget.awesomeController.toggleFullScreen();
      }

      Map<String, Widget> videoProgressWidgets = {
        "rewind": Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                fastRewind();
              },
              child: videoControlBarStyle.rewindIcon,
            )),
        "play": Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: () {
              togglePlay();
            },
            child: widget.awesomeController.isPlaying
                ? videoControlBarStyle.pauseIcon
                : videoControlBarStyle.playIcon,
          ),
        ),
        "forward": Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                fastForward();
              },
              child: videoControlBarStyle.forwardIcon,
            )),

        ///线条视频进度条
        "progress": Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: VideoLinearProgressBar(widget.controller,
                allowScrubbing: widget.awesomeController.options.allowScrubbing,
                // onprogressdrag: widget.onprogressdrag,
                padding: videoControlBarStyle.progressStyle.padding,
                progressStyle: videoControlBarStyle.progressStyle),
          ),
        ),

        ///默认视频进度条
        "basic-progress": Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: VideoDefaultProgressBar(widget.controller,
                allowScrubbing: widget.awesomeController.options.allowScrubbing,
                // onprogressdrag: widget.onprogressdrag,
                progressStyle: videoControlBarStyle.progressStyle),
          ),
        ),

        "time": Padding(
          padding: videoControlBarStyle.timePadding,
          child: Text(
            "$position / $duration",
            style: TextStyle(
              color: videoControlBarStyle.timeFontColor,
              fontSize: videoControlBarStyle.timeFontSize,
            ),
          ),
        ),
        "position-time": Padding(
          padding: widget.videoControlBarStyle.timePadding,
          child: Text(
            "$position",
            style: TextStyle(
              color: widget.videoControlBarStyle.timeFontColor,
              fontSize: widget.videoControlBarStyle.timeFontSize,
            ),
          ),
        ),
        "duration-time": Padding(
          padding: widget.videoControlBarStyle.timePadding,
          child: Text(
            "$duration",
            style: TextStyle(
              color: widget.videoControlBarStyle.timeFontColor,
              fontSize: widget.videoControlBarStyle.timeFontSize,
            ),
          ),
        ),
        "fullscreen": Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: toggleFullScreen,
              child: widget.awesomeController.isFullScreen
                  ? videoControlBarStyle.fullscreenExitIcon
                  : videoControlBarStyle.fullscreenIcon,
            )),
      };

      List<Widget> videoProgressChildrens = [];
      var userSpecifyItem = videoControlBarStyle.itemList;

      for (var i = 0; i < userSpecifyItem.length; i++) {
        videoProgressChildrens.add(videoProgressWidgets[userSpecifyItem[i]]);
      }

      return videoProgressChildrens;
    }

    return AnimatedAlign(
      alignment: Alignment(0, hideContolStuff ? 0 : 50),
      duration: Duration(milliseconds: 300),
      child: Container(
        margin: videoControlBarStyle.margin,
        padding: videoControlBarStyle.padding,
        height: videoControlBarStyle.height,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // if (latestPlayerValue.hasError) {
    //   return Text(controller.value.errorDescription);
    // }

    double containerPadding = 0;
    double width = MediaQuery.of(context).size.width;

    if (widget.awesomeController.isFullScreen && width > 414) {
      width = width - width * 0.8;
      containerPadding = width / 2;
    }

    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          //全屏构建系统状态栏
          // _buildStatusBar(context),
          //构建顶部控制拦
          _buildTopControlBar(context),
          //构建手势等内置控制拦
          Expanded(
            child: Container(),
          ),
          //构建底部控制拦
          _buildBottomControlBar(widget.videoControlBarStyle, context),
        ],
      ),
    );
  }
}
