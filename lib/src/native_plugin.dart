import 'package:flutter/services.dart';

/// Xcode 搜索 `awsome_video_player-umbrella.h`，在文件中添加`#import "Flutter-Bridging-Header.h"`
class NativePlugin {
  static const _methodChannel = const MethodChannel('awsome_video_player');

  static const _eventChannel = const EventChannel('awsome_video_player_event');

  static Future<void> dlnaSearch() async {
    await _methodChannel.invokeMethod(
      'dlna_search',
    );
  }

  /// onDevicesChange 返回的列表下标
  static Future<void> dlnaPlay(String url, {int index = 0}) async {
    await _methodChannel
        .invokeMethod('dlna_play', {"url": url, "index": index});
  }

  static Future<void> dlnaStop() async {
    await _methodChannel.invokeMethod(
      'dlna_stop',
    );
  }

  static Future<bool> dlnaPlayOrPause() async {
    return await _methodChannel.invokeMethod(
      'dlna_playOrPause',
    );
  }

  static Future<void> dlnaVolume(double volume) async {
    await _methodChannel.invokeMethod('dlna_volume', {"volume": volume});
  }

  static Future<void> dlnaSeekTo(int sec) async {
    await _methodChannel.invokeMethod(
      'dlna_seekTo',
    );
  }

  static Future<void> dlnaPlayNext(String url) async {
    await _methodChannel.invokeMethod('dlna_next', {"url": url});
  }

  static Stream<List<String>> _onDevicesChange;

  static Stream<List<String>> get onDevicesChange {
    if (_onDevicesChange == null) {
      _onDevicesChange = _eventChannel
          .receiveBroadcastStream()
          .map((event) => _convert(event));
    }
    return _onDevicesChange;
  }

  static List<String> _convert(String value) {
    if (value == "start") return [value];
    return value.split(",");
  }
}
