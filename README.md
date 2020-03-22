## awsome_video_player
[![pub package](https://img.shields.io/pub/v/awsome_video_player.svg)](https://pub.dartlang.org/packages/awsome_video_player)

一个简单易用的而且可高度自定义的播放器。

![原型图](https://upload-images.jianshu.io/upload_images/4406914-032f148ae9fce8f6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 工欲善其事，必先利其器

闲话不多说我们直接上“干货”。

Q：播放器就播放器，为什么要强调上高度自由呢？
A：之所以强调高度自由是因为播放器上面的能见的元素你都可以去**更改**，同时提供很多的回调可以进行**自定义**处理。主要还是体现在了自定义这个方面。（你可以拿它去仿 blibli ，腾讯播放器等等）

Q：高度自由体现在哪些功能或者配置上面？
A：最能体现自由的是播放器的**自定义拓展元素**功能，但是往往很多集成的开发者都忽略了这一点，因为这个确实很方便，但是很多播放器都没能做到这一点；其次，利用**自定义顶部控制拦**可以添加很多 `actions`操作，通过**自定义拓展元素**这个功能来辅助实现；最后，**自定义底部控制拦**可以**添加或减少**控制元素，更改进度条的样式等等。

Q：播放器目前具备哪些能力？
A：目前还在完善当中，但是功能基本都已经完善了，剩下的就是根据开发者的反馈去优化和完善了，下面是我罗列的功能列表：

- 1.自定义图标（所有）
- 2.播放器自定义配置
  - 视频开始播放的起始位置
  - 是否自动播放
  - 是否循环播放
  - 视频比例
  - 进度条是否允许拖拽
  - 视频快进/快退的单位秒数
- 3.自定义拓展元素（无限）
  - 字幕（也可以使用内置字幕）
  - 弹幕
  - 其他元素（例如：广告覆盖；自定义视频顶部返回按钮；快进或快退等操作的渐入渐出的提示等等）
- 4.自定义播放器样式
  - 播放按钮是否显示（视频暂停时视图中央的播放按钮）
  - 自定义播放按钮（视频暂停时视图中央的播放按钮）
  - 顶部控制栏自定义
    - 显示或隐藏
    - 自定义高度
    - 自定义边距
    - 自定义背景颜色
    - 自定义返回按钮
    - 拓展中部元素（标题）
    - 拓展右侧控制元素（更多操作）
  - 底部控制栏自定义配置
    - 自定义顺序（通过数组来控制元素：线形进度条、矩形进度条等）
    - 自定义元素（通过数组来控制顺序）
    - 自定义背景颜色
    - 自定义图标（播放、暂停、快进、快退、全屏、取消全屏）
    - 进度条样式自由配置（背景颜色、缓存区颜色、进度条颜色、拖拽按钮颜色、拖拽按钮颜色等）
    - 音量控制元素（尚未完成）
    - 内置弹幕（尚未完成，尚可自定义）
    - 控制栏拓展（尚未完成）
  - 内置字幕自定义配置(或者通过自定义拓展来自己重写字幕)
    - 设置主字幕或辅字幕的字体大小
    - 设置主字幕或辅字幕的字体颜色
- 5.手势支持
  - 单击（菜单栏显示或隐藏）
  - 双击（暂停或播放）
  - 滑动快进或快退
  - 滑动调整视频亮度 （左侧区域）
  - 滑动调整音量大小（右侧区域）
- 6.横竖屏切换
- 7.常亮避免锁屏

# 一张效果图
![一张效果图](https://upload-images.jianshu.io/upload_images/4406914-52e18ca5a6522ad4.gif?imageMogr2/auto-orient/strip)

# 前往快乐的源泉

- [Git地址](https://github.com/chudongvip/awsome_video_player)
- [DEMO源码](https://github.com/chudongvip/awsome_video_player/tree/master/example)

# 播放器属性

![逻辑思维图](https://upload-images.jianshu.io/upload_images/4406914-a68e4c8716b78fd9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

通过上图我们可以看一下播放器都有哪些属性呢？

| 属性         | 类型             | 描述                                                         |
| ------------ | ---------------- | ------------------------------------------------------------ |
| dataSource   | String           | 视频URL或媒体文件的路径                        |
| playOptions  | VideoPlayOptions | 视频播放自定义配置，包含是否自动播放，是否循环播放等（详情见下方的**Useage**）                     |
| videoStyle   | VideoStyle       | 视频播放器自定义样式，自定义顶部控制拦样式、自定义底部控制拦样式等（详情见下方的**Useage**）                   |
| children     | List<Widget>     | 自定义拓展的元素，需要使用 Widget `Align`（字幕、弹幕、广告、封面等其他自定义元素） |

| 回调方法         | 类型             | 描述                                                         |
| ------------ | ---------------- | ------------------------------------------------------------ |
| oninit       | VideoCallback    | 初始化完成回调                                              |
| onplay       | VideoCallback    | 视频开始播放的回调                                           |
| onpause      | VideoCallback    | 视频暂停播放回调                                             |
| ontimeupdate | VideoCallback    | 视频播放进度回调（通过返回的value进行字幕匹配）                  |
| onend        | VideoCallback    | 视频播放结束回调                                             |
| onvolume     | VideoCallback    | 播放声音大小变化回调                                          |
| onbrightness | VideoCallback    | 屏幕亮度变化回调                                              |
| onpop        | VideoCallback    | 顶部控制栏返回按钮点击回调                                     |
| onnetwork    | VideoCallback    | 网络变化回调                                                 |
| onfullscreen | VideoCallback    | 视频是否全屏回调                                          |
| onprogressdrag | VideoCallback    | 进度条被拖拽的回调                                          |
<br>

## 播放器自定义配置 (VideoPlayOptions)

| 属性           | 类型     | 描述                                      |
| -------------- | -------- | ----------------------------------------- |
| startPosition  | Duration | 开始播放节点，例如：Duration(seconds: 0)) |
| loop           | bool     | 是否循环播放                              |
| seekSeconds    | num      | 设置视频快进/快退单位秒数，默认为`15s`    |
| autoplay       | bool     | 是否自动播放                              |
| aspectRatio    | num      | 视频播放比例，例如：16/9 或者 4/3           |
| allowScrubbing | bool     | 是否允许进度条拖拽                         |
<br>

## 播放器自定义样式 (VideoStyle)

| 属性                 | 类型                 | 描述                                                                    |
| -------------------- | -------------------- | ----------------------------------------------------------------------- |
| playIcon             | Widget               | 视频暂停播放时中央显示的图标，showPlayIcon为`false`时，该属性设置无效。 |
| showPlayIcon         | bool                 | 暂停时是否显示播放按钮                                                  |
| videoTopBarStyle     | VideoTopBarStyle     | 视频顶部自定义样式（详情见下方的**Useage**）                            |
| videoControlBarStyle | VideoControlBarStyle | 控制栏自定义样式（详情见下方的**Useage**）                              |
| videoSubtitlesStyle  | VideoSubtitles       | 字幕自定义样式（详情见下方的**Useage**）                                |

### 自定义顶部控制栏 (VideoTopBarStyle)：

| 属性               | 类型         | 描述                                                                                              |
| ------------------ | ------------ | ------------------------------------------------------------------------------------------------- |
| show               | bool         | 是否显示控制栏                                                                                    |
| barBackgroundColor | Color        | 控制栏背景颜色，默认为`Color.fromRGBO(0, 0, 0, 0.5)`                                              |
| height             | double       | 自定义控制栏高度                                                                                  |
| padding            | EdgeInsets   | 自定义边距                                                                                        |
| popIcon            | Widget       | 自定义返回按钮                                                                                    |
| contents           | List<Widget> | 拓展控制栏中部元素（宽度自适应： `Row`中的 `Expanded`）                                           |
| actions            | List<Widget> | 拓展控制栏右侧控制元素                                                                            |
| customBar          | Widget       | 重写控制栏（如果设置了`customBar`, 除`show`属性意外上方属性均不生效）,仅支持`Align`和`Positioned` |

![自定义顶部控制栏](https://upload-images.jianshu.io/upload_images/4406914-2f1586e7e4bc450e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 自定义底部控制栏样式 (VideoControlBarStyle)：

| 属性               | 类型         | 描述                                                         |
| ------------------ | ------------ | ------------------------------------------------------------ |
| height             | double       | 控制栏高度，默认为`30`                                          |
| padding            | EdgeInsets   | 控制栏内边距，默认为`EdgeInsets.symmetric(vertical: 8, horizontal: 10)`|
| progressStyle      | VideoProgressStyle| 自定义控制拦进度条样式                                 |
| barBackgroundColor | Color        | 控制栏背景颜色，默认为`Color.fromRGBO(0, 0, 0, 0.5)`        |
| timePadding        | EdgeInsets   | 视频时间的内边距，默认为`EdgeInsets.symmetric(horizontal: 5)`|
| timeFontSize       | double       | 视频时间的字体大小，默认为`8`                                |
| timeFontColor      | Color        | 视频时间的颜色，默认为`Color.fromRGBO(255, 255, 255, 1)`    |
| playIcon           | Widget       | 控制栏播放图标（下`图3`详细说明）                            |
| pauseIcon          | Widget       | 控制栏暂停图标（下`图3`详细说明）                            |
| rewindIcon         | Widget       | 控制栏快退图标（下`图3`详细说明）                            |
| forwardIcon        | Widget       | 控制栏快进图标（下`图3`详细说明）                            |
| fullscreenIcon     | Widget       | 控制栏全屏图标（下`图3`详细说明）                            |
| fullscreenExitIcon | Widget       | 控制栏取消全屏图标（下`图3`详细说明）                         |
| itemList           | List<String> | 控制栏自定义功能（下`图4`详细说明），默认为["rewind", "play", "forward", "position-time", "progress",  "duration-time", "fullscreen"]。如果我们需要调整控制栏显示的顺序，仅需要调整 list 中字符串的顺序，如果需要删减，直接从 list 中移除改字符串即可，例如移除快进和快退，则讲 list 设置为 ["play", "progress","position-time", "progress",  "duration-time", "fullscreen"] 即可。后面会陆续开放自定义元素，也就是你把你的元素加入到 list 中。 |
![图3](https://upload-images.jianshu.io/upload_images/4406914-f317d63e033e47d8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![图4](https://upload-images.jianshu.io/upload_images/4406914-56cc09ec1457254b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 自定义进度条样式 (VideoProgressStyle) ：

| 属性                | 类型         | 描述                                                        |
| ------------------ | ------------ | ---------------------------------------------------------- |
| padding            | EdgeInsets   | 进度条边距（`itemList`中包含`progress`有效）                   |
| height             | double       | 进度条高度（`itemList`中包含`progress`有效）                   |
| dragHeight         | double       | 进度条拖拽按钮高度（`itemList`中包含`progress`有效）            |
| progressRadius     | double       | 进度条圆角（`itemList`中包含`progress`有效）                   |
| playedColor        | Color        | 已播放的进度条颜色（见下图）                            |
| bufferedColor      | Color        | 已缓冲的进度条颜色（见下图）                            |
| backgroundColor    | Color        | 进度条背景颜色（见下图）                               |
| dragBarColor       | Color        | 进度条拖拽按钮演示（`itemList`中包含`progress`有效）            |

![更改颜色](https://upload-images.jianshu.io/upload_images/4406914-55580615c6e2125d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 自定义控制栏功能 (itemList) ：

| 属性           | 类型   | 描述                                                                                                                                                      |
| -------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| rewind         | String | 快退功能，对应`VideoControlBarStyle`的`rewindIcon`图标                                                                                                    |
| play           | String | 播放/暂停功能，对应`VideoControlBarStyle`的`playIcon` `pauseIcon`图标                                                                                     |
| forward        | String | 快进功能，对应`VideoControlBarStyle`的`forwardIcon`图标                                                                                                   |
| progress       | String | 线条形进度条（与‘basic-progress’二选一），由`VideoControlBarStyle`的`progressStyle`控制样式                                                               |
| basic-progress | String | 矩形进度条（与‘progress’二选一），由`VideoControlBarStyle`的`progressStyle`控制样式                                                                       |
| time           | String | 时间格式：当前时间/视频总时长（与`position-time`和`duration-time`二选一），由`VideoControlBarStyle`的`timePadding` `timeFontSize` `timeFontColor`控制样式 |
| position-time  | String | 当前播放时间，样式控制与`time`相同                                                                                                                        |
| duration-time  | String | 视频总时长，样式控制与`time`相同                                                                                                                          |
| fullscreen     | String | 全屏/小屏功能，对应`VideoControlBarStyle`的 `fullscreenIcon` `fullscreenExitIcon`图标                                                                     |

# 如何使用?

## Install & Set up

1. 添加依赖，打开根目录的`pubspec.yaml`文件，在`dependencies:`下面添加以下代码

   ```yaml
   awsome_video_player: #latest
   ```

2. 安装依赖（如果已经自动安装请忽略）

   ```dart
   cd 项目目录
   flutter packages get
   ```

3. 在页面中引入库

   ```dart
   import 'package:awsome_video_player/awsome_video_player.dart';
   ```

## Useage

这是一个完整的DEMO

main.dart

```dart
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
                //barBackgroundColor: Colors.blue,
                /// 自定义进度条样式
                progressStyle: VideoProgressStyle(
                  // padding: EdgeInsets.all(0),
                  playedColor: Colors.red,
                  bufferedColor: Colors.yellow,
                  backgroundColor: Colors.green,
                  dragBarColor: Colors.white,//进度条为`progress`时有效，如果时`basic-progress`则无效
                  height: 4,
                  progressRadius: 2,//进度条为`progress`时有效，如果时`basic-progress`则无效
                  dragHeight: 5//进度条为`progress`时有效，如果时`basic-progress`则无效
                ),
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
                  "position-time", //当前播放时间
                  "progress",//线形进度条
                  //"basic-progress",//矩形进度条
                  "duration-time", //视频总时长
                  // "time", //格式：当前时间/视频总时长
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
            /// 视频初始化完成回调
            oninit: (val) {
              print("video oninit");
            },
            /// 视频播放回调
            onplay: (value) {
              print("video played");
            },
            /// 视频暂停回调
            onpause: (value) {
              print("video paused");
            },
            /// 视频播放结束回调
            onended: (value) {
              print("video ended");
            },
            /// 视频播放进度回调
            /// 可以用来匹配字幕
            ontimeupdate: (value) {
              print("timeupdate $value");
              var position = value.position.inMilliseconds / 1000;
              //根据 position 来判断当前显示的字幕
            },
            /// 声音变化回调
            onvolume: (value) {
              print("onvolume $value");
            },
            /// 亮度变化回调
            onbrightness: (value) {
              print("onbrightness $value");
            },
            /// 网络变化回调
            onnetwork: (value) {
              print("onbrightness $value");
            },
            /// 顶部控制栏点击返回按钮
            onpop: (value) {
              print("返回上一页");
            },
          ),
        ),
      ),
    );
  }
}
```

# DEMO示例

## 1. 自定义控制栏图标

首先我来看一下控制栏的图标自定义（见上图1）:

>DEMO: main.dart

```dart
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

## 2. 自定义控制栏元素和顺序

我们可以根据`videoStyle`中`videoControlBarStyle`来自定义控制栏的样式：调整顺序（见上方图3）只需要调整 `itemList`中字符串的顺序即可；控制显示的元素，将不需要暂时的元素从  `itemList` 中删除即可。

>DEMO: main.dart

```dart
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

## 3. 自定义进度条以及控制栏的背景颜色

同样我们还是通过`videoStyle`中`videoControlBarStyle`来自定义进度条的颜色（见上方图3）。

>DEMO: main.dart

```dart
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
                barBackgroundColor: Colors.blue,//控制栏的背景颜色

                /// 自定义进度条样式
                progressStyle: VideoProgressStyle(
                  // padding: EdgeInsets.all(0),
                  playedColor: Colors.red,
                  bufferedColor: Colors.yellow,
                  backgroundColor: Colors.green,
                  dragBarColor: Colors.white,//进度条为`progress`时有效，如果时`basic-progress`则无效
                  height: 4,
                  progressRadius: 2,//进度条为`progress`时有效，如果时`basic-progress`则无效
                  dragHeight: 5//进度条为`progress`时有效，如果时`basic-progress`则无效
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

## 4. 自定义顶部控制栏

通过`videoStyle`中`videoTopBarStyle`来自定义顶部控制栏。

*DEMO*
![image](https://upload-images.jianshu.io/upload_images/4406914-bdfbb943f7b2f88d?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>DEMO: main.dart

```dart
import 'package:flutter/material.dart';
import 'package:awsome_video_player/awsome_video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String videoUrl = "https://www.runoob.com/try/demo_source/movie.mp4";
  bool showAdvertCover = false;//是否显示广告

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
          child: videoUrl != ""
              ? AwsomeVideoPlayer(
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

                    /// 自定义顶部控制栏
                    videoTopBarStyle: VideoTopBarStyle(
                      show: true, //是否显示
                      height: 30,
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                              style: TextStyle(color: Colors.white),
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
                      // customBar: Text("123123132")
                    ),
                  ),

                  /// 顶部控制栏点击返回按钮
                  onpop: (value) {
                    print("返回上一页");
                  },
                )
              : AspectRatio(
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

# 注意事项（Q&A）

- 视频如果需要横竖屏不能使用safeArea

- 顶部控制拦或者底部控制拦文字或者图标被裁剪，调整字体或图标大小，也可以通过调整控制拦高度

- 视频的 `dataSoure`不能为空，为空时使用加载视图，否则播放器会报错

  ```dart
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

开发过程中遇到问题，请通过以下方式联系我，我会第一时间回复你：

- 联系我
  QQ：604748948
  QQ群：160612343
  微信：cheampie
  ![微信谈论组](https://upload-images.jianshu.io/upload_images/4406914-23fb39bde3e8d69d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- Report
  - [BUG](https://github.com/chudongvip/awsome_video_player/issues/new?title=[Bug%20Report]&body=%20%3C!--%20generated%20by%20third%20party%20platform%20%20--%3E)

  - [需求](https://github.com/chudongvip/awsome_video_player/issues/new?title=[Demand%20Report]&body=%20%3C!--%20generated%20by%20third%20party%20platform%20%20--%3E)

  - [建议](https://github.com/chudongvip/awsome_video_player/issues/new?title=[Advice%20Report]&body=%20%3C!--%20generated%20by%20third%20party%20platform%20%20--%3E)

# License

Copyright © 2020, Mark Chen.  All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.