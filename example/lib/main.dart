import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:awesome_video_player/awesome_video_player.dart';
import 'package:flutter/services.dart';

class AwesomeVideoPlayerPage extends StatefulWidget {
  @override
  _AwesomeVideoPlayerPageState createState() => _AwesomeVideoPlayerPageState();
}

class _AwesomeVideoPlayerPageState extends State<AwesomeVideoPlayerPage> {
  AwesomeVideoValue videoPlayerOptions;

  AwesomeVideoController awesomeController;

  VideoPlayerController controller;

  double playerVolume = 1.0;

  String mainSubtitles = ""; //主字幕

  String subSubtitles = ""; //辅字幕

  //flags
  bool showAdvertCover = false; //是否显示广告

  void updateSource() {
    awesomeController?.dispose();
    controller?.pause();
    controller?.seekTo(Duration(seconds: 0));
    controller = VideoPlayerController.network(
        "https://yun.zxziyuan-yun.com/20180221/4C6ivf8O/index.m3u8");
    awesomeController = AwesomeVideoController(
        videoPlayerController: controller, options: videoPlayerOptions);
  }

  @override
  void initState() {
    super.initState();

    videoPlayerOptions = AwesomeVideoValue(
        autoInitialize: true,
        autoPlay: true,
        loop: false,
        allowScrubbing: true,
        // startPosition: Duration(seconds: 11),
        showControlsOnInitialize: false,
        fullScreenByDefault: true);

    controller = VideoPlayerController.network(
        "https://www.runoob.com/try/demo_source/movie.mp4");

    awesomeController = AwesomeVideoController(
        videoPlayerController: controller, options: videoPlayerOptions);
  }

  @override
  void dispose() {
    awesomeController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(children: <Widget>[
        AwesomeVideoPlayer(
          controller: awesomeController,

          /// 自定义视频样式
          videoStyle: VideoStyle(
            /// 自定义视频暂停时视频中部的播放按钮
            playIcon: Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.white,
            ),

            /// 暂停时是否显示视频中部播放按钮
            showPlayIcon: true,

            videoLoadingStyle: VideoLoadingStyle(
              /// 重写部分（二选一）
              // 重写Loading的widget
              // customLoadingIcon: CircularProgressIndicator(strokeWidth: 2.0),
              // 重写Loading 下方的Text widget
              // customLoadingText: Text("加载中..."),
              /// 设置部分（二选一）
              // 设置Loading icon 下方的文字
              loadingText: "Loading...",
              // 设置loading icon 下方的文字颜色
              loadingTextFontColor: Colors.white,
              // 设置loading icon 下方的文字大小
              loadingTextFontSize: 20,
            ),

            /// 自定义顶部控制栏
            videoTopBarStyle: VideoTopBarStyle(
              show: true, //是否显示
              height: 30,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              barBackgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
              popIcon: Icon(
                Icons.arrow_back,
                size: 16,
                color: Colors.white,
              ),
              contents: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '123',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                )
              ], //自定义顶部控制栏中间显示区域
              actions: [
                GestureDetector(
                  onTap: () {
                    ///1. 可配合自定义拓展元素使用，例如广告
                    setState(() {
                      showAdvertCover = true;
                    });

                    ///
                  },
                  child: Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: Colors.white,
                  ),
                )
              ], //自定义顶部控制栏右侧显示区域
              /// 设置cusotmBar之后，以上属性均无效(除了`show`之外)
              // customBar: Positioned(
              //   top: 0,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     width: double.infinity,
              //     height: 50,
              //     color: Colors.yellow,
              //     child: Text("12312312"),
              //   ),
              // ),
              // customBar: Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     width: double.infinity,
              //     height: 30,
              //     color: Colors.yellow,
              //     child: GestureDetector(
              //       onTap: () {
              //         print("yes");
              //       },
              //       child: Text("123123132")
              //     )
              //   ),
              // ),
            ),

            /// 自定义底部控制栏
            videoControlBarStyle: VideoControlBarStyle(
              /// 自定义颜色
              // barBackgroundColor: Colors.blue,

              ///添加边距
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),

              ///设置控制拦的高度，默认为30，如果图标设置过大但是高度不够就会出现图标被裁剪的现象
              height: 30,

              /// 自定义进度条样式
              // progressStyle: VideoProgressStyle(
              //     // padding: EdgeInsets.all(0),
              //     padding: EdgeInsets.symmetric(
              //         vertical: 0,
              //         horizontal: 10), //vertical不能设置太大，不然被把进度条压缩肉眼无法识别
              //     playedColor: Colors.red,
              //     bufferedColor: Colors.yellow,
              //     backgroundColor: Colors.green,
              //     dragBarColor: Colors
              //         .white, //进度条为`progress`时有效，如果时`basic-progress`则无效
              //     height: 4,
              //     progressRadius:
              //         2, //进度条为`progress`时有效，如果时`basic-progress`则无效
              //     dragHeight:
              //         5 //进度条为`progress`时有效，如果时`basic-progress`则无效
              //     ),

              /// 更改进度栏的播放按钮
              playIcon: Icon(Icons.play_arrow, color: Colors.white, size: 16),

              /// 更改进度栏的暂停按钮
              pauseIcon: Icon(
                Icons.pause,
                color: Colors.white,
                size: 16,
              ),

              /// 更改进度栏的快退按钮
              rewindIcon: Icon(
                Icons.replay_30,
                size: 16,
                color: Colors.white,
              ),

              /// 更改进度栏的快进按钮
              forwardIcon: Icon(
                Icons.forward_30,
                size: 16,
                color: Colors.white,
              ),

              /// 更改进度栏的全屏按钮
              fullscreenIcon: Icon(
                Icons.fullscreen,
                size: 20,
                color: Colors.white,
              ),

              /// 更改进度栏的退出全屏按钮
              fullscreenExitIcon: Icon(
                Icons.fullscreen_exit,
                size: 20,
                color: Colors.red,
              ),

              /// 决定控制栏的元素以及排序，示例见上方图3
              itemList: [
                "rewind",
                "play",
                "forward",
                "position-time", //当前播放时间
                "progress", //线条形进度条（与‘basic-progress’二选一）
                // "basic-progress",//矩形进度条（与‘progress’二选一）
                "duration-time", //视频总时长
                // "time",//格式：当前时间/视频总时长
                "fullscreen"
              ],
            ),

            /// 自定义字幕
            videoSubtitlesStyle: VideoSubtitles(
              mianTitle: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
                  child: Text(mainSubtitles,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
              subTitle: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(subSubtitles,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ),
          ),

          /// 自定义拓展元素
          children: [
            /// DEMO1 自定义视频播放状态Toast
            /// 待完善

            /// DEMO2 这个将会覆盖的视频内容，因为这个层级是最高级，因此手势会失效(慎用)
            /// 这个可以用来做视频广告
            showAdvertCover
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 200,
                      height: 100,
                      color: Colors.blue[500],
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          //关闭广告
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAdvertCover = false;
                                });
                              },
                              child: Icon(
                                Icons.cancel,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              "一个广告封面",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Align(),
          ],
        ),
        Wrap(
          spacing: 8.0, // 主轴(水平)方向间距
          runSpacing: 4.0, // 纵轴（垂直）方向间距
          alignment: WrapAlignment.center, //沿主
          children: <Widget>[
            RaisedButton(
              child: Text("start play"),
              onPressed: () {
                controller.play();
              },
            ),
            RaisedButton(
              child: Text("pause video"),
              onPressed: () {
                awesomeController.pause();
              },
            ),
            RaisedButton(
              child: Text("forward 5 seconds"),
              onPressed: () {
                var currentPosition = controller.value.position;
                awesomeController
                    .seekTo(Duration(seconds: currentPosition.inSeconds + 5));
              },
            ),
            RaisedButton(
              child: Text("reverse 5 seconds"),
              onPressed: () {
                var currentPosition = controller.value.position;
                awesomeController
                    .seekTo(Duration(seconds: currentPosition.inSeconds - 5));
              },
            ),
            RaisedButton(
              child: Text("update source"),
              onPressed: updateSource,
              // onPressed: () {
              //   controller?.pause();
              //   controller?.seekTo(Duration(seconds: 0));
              //   // controller?.dispose();
              //   controller = AwesomeVideoController.network(
              //       "https://yun.zxziyuan-yun.com/20180221/4C6ivf8O/index.m3u8",
              //       options: videoPlayerOptions);
              // },
            ),
            RaisedButton(
              child: Text("request FullScreen"),
              onPressed: () {
                awesomeController.requestFullScreen();
              },
            ),
            RaisedButton(
              child: Text("cancel FullScreen"),
              onPressed: () {
                awesomeController.exitFullScreen();
              },
            ),
            Slider(
                label: 'Slider $playerVolume',
                min: 0,
                max: 1,
                value: playerVolume,
                activeColor: Colors.blue,
                onChanged: (double v) {
                  setState(() {
                    playerVolume = v;
                  });
                },
                onChangeStart: (double startValue) {
                  print('Started change at $startValue');
                },
                onChangeEnd: (double newValue) {
                  print('Ended change on $newValue');
                }),
            RaisedButton(
              child: Text("set volume"),
              onPressed: () {
                controller.setVolume(playerVolume);
              },
            )
          ],
        )
      ]),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("Awesome Video Player"),
      ),
      body: AwesomeVideoPlayerPage(),
    ));
  }
}
