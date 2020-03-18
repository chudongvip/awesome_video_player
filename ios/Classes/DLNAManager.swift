//
//  DLNAManager.swift
//  awsome_video_player
//
//  Created by Jerome Xiong on 2020/3/16.
//

import Foundation

enum DLNAAction {
    case search([CLUPnPDevice])
    case start
}
class DLNAManager: NSObject {
    fileprivate lazy var dlnaManager: MRDLNA = {
        let manager = MRDLNA.sharedMRDLNAManager()!
        manager.delegate = self
        return manager
    }()
    
    var onAction: ((DLNAAction)->Void)?
    fileprivate var searchStart = false
    fileprivate(set) var isPlaying: Bool = false
    fileprivate(set) var devices = [CLUPnPDevice]()
    fileprivate(set) var curIdx = -1
    
    public static let `default`: DLNAManager = {
        let manager = DLNAManager()
        return manager
    }()
    private override init() {
        super.init()
    }
    
    func search() {
        if searchStart { return }
        dlnaManager.startSearch()
        searchStart = true
    }
    /// 投屏
    func play(_ url: String, index: Int) {
        if index < 0 || index >= devices.count {
            return
        }
        if curIdx != -1 { stop() }
        let device = devices[index]
        
        dlnaManager.device = device
        dlnaManager.playUrl = url
        dlnaManager.start()
        isPlaying = true
        curIdx = index
    }
    func stop() {
        dlnaManager.end()
        isPlaying = false
        curIdx = -1
    }
    func playOrPause() {
        if prejudge { return }
        if isPlaying {
            dlnaManager.dlnaPause()
        }else {
            dlnaManager.dlnaPlay()
        }
        isPlaying = !isPlaying
    }
    /// 切集
    func playNext(_ url: String) {
        if prejudge { return }
        dlnaManager.playTheURL(url)
    }
    /// 设置音量 volume建议传0-100
    func volumeChanged(_ volume: Double) {
        if prejudge { return }
        var volume = max(volume, 0)
        volume = min(volume, 100)
        dlnaManager.volumeChanged("\(volume)")
    }
    /// 设置播放进度 单位是秒
    func seekTo(_ sec: Int) {
        if prejudge { return }
        dlnaManager.seekChanged(sec)
    }
    /// 是否不通过判断
    fileprivate var prejudge: Bool {
        return curIdx == -1
    }
}
extension DLNAManager: DLNADelegate {
    func searchDLNAResult(_ devicesArray: [Any]!) {
        searchStart = false
        guard let devices = devicesArray as? [CLUPnPDevice] else {
            return
        }
        self.devices = devices
        print("----\(devices.description)")
        onAction?(.search(devices))
    }
    func dlnaStartPlay() {
        onAction?(.start)
    }
}
