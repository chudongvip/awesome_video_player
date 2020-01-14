import 'package:flutter/material.dart';

import 'package:awsome_video_player/awsome_video_player.dart';

void main() => runApp(MyApp());

// class CustomizeToastWidget extends StatelessWidget {
//   CustomizeToastWidget({ Key key, this.icon , this.title });

//   final Widget icon;
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.center,
//       child: Center(
//         child: Container(
//           width: 150,
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//             color: Color.fromRGBO(0, 0, 0, .5),
//             borderRadius: BorderRadius.all(Radius.circular(4)),
//           ),
//           child: Row(
//             children: <Widget>[
//               icon,
//               Text(title, style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.white,
//               )),
//               // Icon(
//               //   isPlaying ? Icons.play_arrow : Icons.pause,
//               //   size: 30,
//               //   color: Colors.white,
//               // ),
//               // Text(isPlaying ? "开始播放" : "播放暂停", style: TextStyle(
//               //   fontSize: 20,
//               //   color: Colors.white,
//               // ))
//             ],
//           ),
//         ),
//       )
//     );
//   }
// }


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String videoUrl = "https://www.runoob.com/try/demo_source/movie.mp4";

	String mainSubtitles = "";//主字幕
	String subSubtitles = "";//辅字幕
  bool _isPlaying = false;

  // Widget toast;

  bool get isPlaying => _isPlaying;
  set isPlaying(bool playing) {
    print("playing  $playing");
    _isPlaying = playing;

    // if (playing) {
    //   toast = CustomizeToastWidget(
    //     icon: Icon(
    //       Icons.play_arrow,
    //       size: 30,
    //       color: Colors.white,
    //     ),
    //     title: "开始播放",
    //   );
    // } else {
    //   toast = CustomizeToastWidget(
    //     icon: Icon(
    //       Icons.pause,
    //       size: 30,
    //       color: Colors.white,
    //     ),
    //     title: "播放暂停",
    //   );
    // }
    
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Awsome video player'),
        ),
        body: Center(
          child: videoUrl != "" ? AwsomeVideoPlayer(
            videoUrl,
            /// 视频播放配置
            playOptions: VideoPlayOptions(
              seekSeconds: 30,
              aspectRatio: 16 / 9,
              loop: true,
              autoplay: true,
              allowScrubbing: true,
              startPosition: Duration(seconds: 0)),
            /// 自定义视频样式              
            videoStyle: VideoStyle(
            	/// 自定义视频暂停时视频中部的播放按钮
              playIcon: Icon(
                Icons.play_circle_outline,
                size: 100,
                color: Colors.white,
              ),
              /// 暂停时是否显示视频中部播放按钮              
              showPlayIcon: true,
              /// 自定义底部控制栏              
              videoControlBarStyle: VideoControlBarStyle(       
                /// 自定义颜色
                //playedColor: Colors.red,
                //bufferedColor: Colors.yellow,
                //backgroundColor: Colors.green,
                //barBackgroundColor: Colors.blue,
                /// 更改进度栏的播放按钮
                playIcon: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16
                ),
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
                  size: 16,
                  color: Colors.white,
                ),
                /// 更改进度栏的退出全屏按钮
                fullscreenExitIcon: Icon(
                  Icons.fullscreen_exit,
                  size: 16,
                  color: Colors.red,
                ),
                /// 决定控制栏的元素以及排序，示例见上方图3
                itemList: [
                  "rewind",
                  "play",
                  "forward",
                  "progress",
                  "time",
                  "fullscreen"
                ],
              ),
              /// 自定义字幕
              videoSubtitlesStyle: VideoSubtitles(
              	mianTitle: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
                    child: Text(
                    		mainSubtitles,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontSize: 14)),
                  ),
                ),
                subTitle: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                    		subSubtitles,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontSize: 14)),
                  ),
                ),
              ),
            ),
            /// 自定义拓展元素
            children: [
              /// DEMO1 自定义视频播放状态Toast
              /// 待完善

            	/// DEMO2 添加自定义视频顶部返回按钮
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: GestureDetector(
              //     onTap: () {
              //       print("This is test from children.");
              //     },
              //     child: Container(
              //       margin: EdgeInsets.only(top: 5, left: 5),
              //       width: 30,
              //       height: 30,
              //       decoration: BoxDecoration(
              //         color: Color.fromRGBO(0, 0, 0, .5),
              //         borderRadius: BorderRadius.all(Radius.circular(15)),
              //       ),
              //       child: Icon(Icons.arrow_back, size: 16, color: Colors.white,)
              //     ),
              //   ),
              // ),

              /// DEMO3 这个将会覆盖的视频内容，因为这个层级是最高级，因此手势会失效(慎用)
              /// 这个可以用来做视频广告
              // Positioned(
              //   top: 0,
              //   left: 0,
              //   bottom: 0,
              //   right: 0,
              //   child: Text("data", style: TextStyle(color: Colors.white),),
              // ),
            ],
            /// 视频暂停回调
            onpause: (value) {
              print("video paused");
              setState(() {
                isPlaying = false;  
              });
            },
            /// 视频播放回调
            onplay: (value) {
              print("video played");
              setState(() {
                isPlaying = true;  
              });
            },
            /// 视频播放结束回调
            onended: (value) {
              print("video ended");
            },
            /// 视频播放进度回调
            /// 可以用来匹配字幕
            ontimeupdate: (value) {
              print("timeupdate ${value}");
              var position = value.position.inMilliseconds / 1000;
              //根据 position 来判断当前显示的字幕
            },
          ) : AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        ),
      ),
    );
  }
}
