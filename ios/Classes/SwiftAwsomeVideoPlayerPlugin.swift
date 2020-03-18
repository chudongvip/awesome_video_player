import Flutter
import UIKit

public class SwiftAwsomeVideoPlayerPlugin: NSObject, FlutterPlugin {
    fileprivate var sink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "awsome_video_player", binaryMessenger: registrar.messenger())
        let event = FlutterEventChannel(name: "awsome_video_player_event", binaryMessenger: registrar.messenger())
        
        let instance = SwiftAwsomeVideoPlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        event.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? Dictionary<String,Any> ?? [:]
        switch call.method {
        case "dlna_search":
            DLNAManager.default.search()
        case "dlna_play":
            guard let url = arguments["url"] as? String,
                let index = arguments["index"] as? Int else {
                    result("参数错误")
                    return
            }
            DLNAManager.default.play(url, index: index)
        case "dlna_stop":
            DLNAManager.default.stop()
        case "dlna_playOrPause":
            DLNAManager.default.playOrPause()
            result(DLNAManager.default.isPlaying)
        case "dlna_next":
            guard let url = arguments["url"] as? String else {
                result("参数错误")
                return
            }
            DLNAManager.default.playNext(url)
        case "dlna_volume":
            guard let volume = arguments["volume"] as? Double else {
                result("参数错误")
                return
            }
            DLNAManager.default.volumeChanged(volume)
        case "dlna_seekTo":
            guard let sec = arguments["sec"] as? Int else {
                result("参数错误")
                return
            }
            DLNAManager.default.seekTo(sec)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension SwiftAwsomeVideoPlayerPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        DLNAManager.default.onAction = {[weak self] action in
            guard let `self` = self else {
                return
            }
            switch action {
            case .search(let devices):
                let names = devices.map({$0.friendlyName!})
                let msg = names.joined(separator: ",")
                self.sink?(msg)
            case .start:
                self.sink?("start")
            }
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
