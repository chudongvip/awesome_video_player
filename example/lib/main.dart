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
  AwesomeVideoController controller = AwesomeVideoController.network(
      "https://www.runoob.com/try/demo_source/movie.mp4",
      options: AwesomeVideoValue(
          autoInitialize: true,
          autoPlay: false,
          loop: true,
          fullScreenByDefault: false));

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      AwesomeVideoPlayer(controller: controller),
      Wrap(
        spacing: 8.0, // 主轴(水平)方向间距
        runSpacing: 4.0, // 纵轴（垂直）方向间距
        alignment: WrapAlignment.center, //沿主
        children: <Widget>[
          RaisedButton(
            child: Text("播放"),
            onPressed: () {
              controller.play();
            },
          ),
          RaisedButton(
            child: Text("暂停"),
            onPressed: () {
              controller.pause();
            },
          ),
          RaisedButton(
            child: Text("快进5秒"),
            onPressed: () {
              var currentPosition =
                  controller.videoPlayerController.value.position;
              controller
                  .seekTo(Duration(seconds: currentPosition.inSeconds + 5));
            },
          ),
          RaisedButton(
            child: Text("快退5秒"),
            onPressed: () {
              var currentPosition =
                  controller.videoPlayerController.value.position;
              controller
                  .seekTo(Duration(seconds: currentPosition.inSeconds - 5));
            },
          ),
          // RaisedButton(
          //   child: Text("结束"),
          //   onPressed: () {
          //     controller.end();
          //   },
          // ),
          RaisedButton(
            child: Text("全屏"),
            onPressed: () {
              controller.requestFullScreen();
            },
          ),
          RaisedButton(
            child: Text("取消全屏"),
            onPressed: () {
              controller.exitFullScreen();
            },
          )
        ],
      )
    ]);
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
