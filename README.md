# 一个高自由度的Flutter 视频播放器

![原型图](https://user-gold-cdn.xitu.io/2020/1/14/16fa3bd931fd7bbc?w=798&h=428&f=png&s=13556)

### 写在前面

对！这就是一个播放器，是不是你正在找的哪一款？我们往往写项目都是先写，总想着先写后面有时间了再来优化，然后却是一个永远不会执行的`else`语句。什么叫高度自由的播放器呢？我是这么认为的，首先开放很多可配置的属性，其次需要跟业务代码解耦，这还没有完，我们再升华一下，让视频播放器实现可定制化拓展，也就是说当前播放器满足不了自己需求的时候，我们不再需要等待作者来更新，你可以自己实现更改，例如视频的`字幕`，`弹幕`，`视频顶部控制栏`等。


![](https://user-gold-cdn.xitu.io/2020/1/14/16fa3cfd062a9d73?w=480&h=800&f=gif&s=4666970)

<center>一张效果图</center>

### 高自由度的播放器应该具备哪些功能？

- 1.所有图标均可自定义
- 2.播放器自定义配置
  - 快进快退间隔
  - 是否自动播放
  - 是否循环播放
  - 视频比例
  - 进度条是否允许拖拽
  - 开始播放结点
  - 是否开启横竖屏
- 3.无限拓展子元素
- 字幕
  - 弹幕
  - 其他元素（例如：自定义视频顶部返回按钮；快进或快退等操作的浮层提示等等）
- 4.自定义播放器样式
  - 是否显示播放/暂停的按钮 
  - 自定义暂停时的播放图标

  - 控制栏自定义配置
    - 自定义顺序（通过数组来控制元素）
    - 自定义元素（通过数组来控制顺序）
    - 自定义背景颜色
    - 自定义图标（播放、暂停、快进、快退、全屏、取消全屏）
    - 进度条样式自由配置（背景颜色、缓存区颜色、进度条颜色）
    - 音量控制元素（尚未完成）
    - 内置弹幕（尚未完成，尚可自定义）
  - 控制栏拓展
- 5.手势支持
- 单击（菜单栏显示或隐藏）
  - 双击（暂停或播放）
  - 滑动快进或快退（未完成）
- 6.横竖屏切换
- 7.常亮避免锁屏



### 一图胜千言

![](https://user-gold-cdn.xitu.io/2020/1/14/16fa3bf3d5f005e5?w=1217&h=763&f=png&s=42866)

通过上图我们可以看一下播放器都有哪些属性呢？

**播放器属性：**

| 类型             | 属性         | 描述                                                         |
| ---------------- | ------------ | ------------------------------------------------------------ |
| String           | dataSource   | 视频URL或媒体文件的路径                                      |
| List<Widget>     | children     | 自定义拓展的子元素，需要使用 Widget`Align`（字幕、弹幕、视频顶部控制栏等） |
| VideoCallback    | onplay       | 视频开始播放的回调                                           |
| VideoCallback    | onpause      | 视频暂停播放回调                                             |
| VideoCallback    | ontimeupdate | 视频播放进度回调（通过返回的value进行字幕匹配）              |
| VideoCallback    | onend        | 视频播放结束回调                                             |
| VideoPlayOptions | playOptions  | 视频播放自定义配置（详情见下方的**Useage**）                 |
| VideoStyle       | videoStyle   | 视频播放器自定义样式（详情见下方的**Useage**）               |



**播放器自定义配置 (VideoPlayOptions)：**

| 类型     | 属性           | 描述                                      |
| -------- | -------------- | ----------------------------------------- |
| Duration | startPosition  | 开始播放节点，例如：Duration(seconds: 0)) |
| bool     | loop           | 是否循环播放                              |
| num      | seekSeconds    | 设置视频快进/快退单位秒数                 |
| bool     | autoplay       | 是否自动播放                              |
| num      | aspectRatio    | 视频播放比例，例如：16/9 或者 4/3         |
| bool     | allowScrubbing | 是否运行进度条拖拽                        |



**播放器自定义样式 (VideoStyle)：**

| 类型                 | 属性                 | 描述                                                         |
| -------------------- | -------------------- | ------------------------------------------------------------ |
| Widget               | playIcon             | 视频暂停播放时中央显示的图标，showPlayIcon为`false`时，该属性设置无效。 |
| bool                 | showPlayIcon         | 暂停时是否显示播放按钮                                       |
| VideoControlBarStyle | videoControlBarStyle | 控制栏自定义样式                                             |
| VideoSubtitles       | videoSubtitlesStyle  | 字幕自定义样式                                               |



**控制栏自定义样式 (VideoControlBarStyle)：**

| 类型         | 属性               | 描述                                                         |
| ------------ | ------------------ | ------------------------------------------------------------ |
| Color        | barBackgroundColor | 控制栏背景颜色，默认为`Color.fromRGBO(0, 0, 0, 0.5)`         |
| Color        | playedColor        | 已播放的进度条颜色（下`图1`详细说明）                        |
| Color        | bufferedColor      | 已缓冲的进度条颜色（下`图1`详细说明）                        |
| Color        | backgroundColor    | 进度条背景颜色（下`图1`详细说明）                            |
| Widget       | playIcon           | 控制栏播放图标（下`图2`详细说明）                            |
| Widget       | pauseIcon          | 控制栏暂停图标（下`图2`详细说明）                            |
| Widget       | rewindIcon         | 控制栏快退图标（下`图2`详细说明）                            |
| Widget       | forwardIcon        | 控制栏快进图标（下`图2`详细说明）                            |
| Widget       | fullscreenIcon     | 控制栏全屏图标（下`图2`详细说明）                            |
| Widget       | fullscreenExitIcon | 控制栏取消全屏图标（下`图2`详细说明）                        |
| List<String> | itemList           | 控制栏自定义功能（下`图3`详细说明），默认为["rewind", "play", "forward",  "progress",  "time", "fullscreen"]。如果我们需要调整控制栏显示的顺序，仅需要调整 list 中字符串的顺序，如果需要删减，直接从 list 中移除改字符串即可，例如移除快进和快退，则讲 list 设置为 ["play", "progress",  "time", "fullscreen"] 即可。后面会陆续开放自定义元素，也就是你把你的元素加入到 list 中。 |

![控制栏颜色自定义](https://user-gold-cdn.xitu.io/2020/1/14/16fa3bfbc4f63f60?w=960&h=402&f=png&s=24998)

<center><i>图1</i></center>

![图标自定义](https://user-gold-cdn.xitu.io/2020/1/14/16fa3c013a3a8520?w=1037&h=481&f=png&s=20143)

<center><i>图2</i></center>

![控制栏进度条自定义元素](https://user-gold-cdn.xitu.io/2020/1/14/16fa3c04dd751021?w=963&h=544&f=png&s=30857)

<center><i>图3</i></center>

# 如何使用？

## Install & Set up

1. 添加依赖，打开根目录的`pubspec.yaml`文件，在`dependencies:`下面添加以下代码

   ```yaml
   awsome_video_player: #latest
   ```

2. 安装依赖（如果已经自动安装请忽略）

   ```
   cd 项目目录
   flutter packages get
   ```

3. 在页面中引入库

    ```
    import 'package:awsome_video_player/awsome_video_player.dart';
    ```

## Useage

这是一个完整的

main.dart

```
import 'package:flutter/material.dart';

import 'package:awsome_video_player/awsome_video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String mainSubtitles = "主字幕";
  String subSubtitles = "辅字幕";

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
          child: AwsomeVideoPlayer(
            "https://www.runoob.com/try/demo_source/movie.mp4",
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
                  color: Colors.red,
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
            	/// 添加自定义视频顶部返回按钮
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    print("This is test from children.");
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 5, left: 5),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, .5),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Icon(Icons.arrow_back, size: 16, color: Colors.white,)
                  ),
                ),
              ),

              /// 这个将会覆盖的视频内容，因为这个层级是最高级，因此手势会失效(慎用)
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
            },
            /// 视频播放回调
            onplay: (value) {
              print("video played");
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
          ),
        ),
      ),
    );
  }
}
```



# 示例展示

#### 1. 自定义控制栏图标

首先我来看一下控制栏的图标自定义:

![](https://user-gold-cdn.xitu.io/2020/1/14/16fa3c1561a047aa?w=1037&h=481&f=png&s=20143)

代码：main.dart

```
import 'package:flutter/material.dart';

import 'package:awsome_video_player/awsome_video_player.dart';

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
          title: const Text('Awsome video player'),
        ),
        body: Center(
          child: AwsomeVideoPlayer(
            "https://www.runoob.com/try/demo_source/movie.mp4",
            /// 视频播放配置
            playOptions: VideoPlayOptions(
              seekSeconds: 30,
              aspectRatio: 16 / 9,
              loop: true,
              autoplay: true,
              allowScrubbing: true,
              startPosition: Duration(seconds: 0)),
            /// 自定义视频样式 - 请注意我要划重点了
            videoStyle: VideoStyle(
              /// 自定义底部控制栏  - 这是重点了
              videoControlBarStyle: VideoControlBarStyle(       
                /// 更改进度栏的播放按钮
                playIcon: Icon(
                  Icons.play_arrow, 
                  color: Colors.white, 
                  size: 16
                ),
                /// 更改进度栏的暂停按钮
                pauseIcon: Icon(
                  Icons.pause,
                  color: Colors.red,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```


#### 2. 自定义控制栏元素和顺序

我们可以根据`videoStyle`中`videoControlBarStyle`来自定义控制栏的样式：调整顺序（见上方图3）只需要调整 `itemList`中字符串的顺序即可；控制显示的元素，将不需要暂时的元素从  `itemList` 中删除即可。

```
import 'package:flutter/material.dart';

import 'package:awsome_video_player/awsome_video_player.dart';

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
          title: const Text('Awsome video player'),
        ),
        body: Center(
          child: AwsomeVideoPlayer(
            "https://www.runoob.com/try/demo_source/movie.mp4",
            /// 视频播放配置
            playOptions: VideoPlayOptions(
              seekSeconds: 30,
              aspectRatio: 16 / 9,
              loop: true,
              autoplay: true,
              allowScrubbing: true,
              startPosition: Duration(seconds: 0)),
            /// 自定义视频样式 - 请注意我要划重点了
            videoStyle: VideoStyle(
              /// 自定义底部控制栏  - 这是重点了
              videoControlBarStyle: VideoControlBarStyle(       
                /// 决定控制栏的元素以及排序，示例见上方图3
                itemList: [
                  "progress",// 这里将进度条前置了，因此有了图3的效果
                  "rewind",//如果需要删除快退按钮，将其注释或删除即可
                  "play",
                  "forward",
                  "time",
                  "fullscreen"
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```



#### 3. 自定义进度条以及控制栏的背景颜色

同样我们还是通过`videoStyle`中`videoControlBarStyle`来自定义进度条的颜色（见上方图3）。

```
import 'package:flutter/material.dart';

import 'package:awsome_video_player/awsome_video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

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
          child: AwsomeVideoPlayer(
            "https://www.runoob.com/try/demo_source/movie.mp4",
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
              /// 自定义底部控制栏              
              videoControlBarStyle: VideoControlBarStyle(       
                /// 自定义颜色
                playedColor: Colors.red,//已播放进度条的颜色
                bufferedColor: Colors.yellow,//已缓存进度条的颜色
                backgroundColor: Colors.green,//进度条的背景颜色
                barBackgroundColor: Colors.blue,//控制栏的背景颜色
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```



### 注意事项（Q&A）

- 视频如果需要横竖屏不能使用safeArea

- 视频的 `dataSoure`不能为空，为空时使用加载视图，否则播放器会报错

  ```
  import 'package:flutter/material.dart';
  
  import 'package:awsome_video_player/awsome_video_player.dart';
  
  void main() => runApp(MyApp());
  
  class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => _MyAppState();
  }
  
  class _MyAppState extends State<MyApp> {
  
    String videoUrl = "https://www.runoob.com/try/demo_source/movie.mp4";
  
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
          	/// 一般videoUrl是从服务端返回，在没有返回来之前，
          	/// 我们可以使用加载视图来占位
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
  
  ```

  

- `AwsomeVideoPlayer`下面的`children`仅支持`Align`和`Positioned`，children的层级会高于下面，这个功能会持续更新，后面会陆续出一些针对自定义拓展的高阶文档。



# 写在最后

开发过程中遇到问题，请通过下面的微信或者微信群进行提问或者[点击](https://github.com/chudongvip/awsome_video_player/issues/new?title=\[Question%20report%20\]%20XXX%20&body=%3C!--%20generated%20by%20README%20--%3E)这里，如果需要上报BUG可以[点击这里](https://github.com/chudongvip/awsome_video_player/issues/new?title=[Bug%20report]%20XXX%20&body)，我会第一时间回复你，期待与你的讨论。

![](https://user-gold-cdn.xitu.io/2020/1/14/16fa3c3f3a1a0851?w=285&h=283&f=png&s=41025)

<center>我的微信</center>

![](https://user-gold-cdn.xitu.io/2020/1/14/16fa3c41ee67d888?w=295&h=294&f=png&s=29131)

<center>扫码进入技术进阶交流群</center>

# License

Copyright © 2020, Mark Chen.  All rights reserved. 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.