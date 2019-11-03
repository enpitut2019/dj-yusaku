//
//  PlayerQueue.swift
//  DJYusaku
//
//  Created by Yuu Ichikawa on 2019/10/24.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

extension Notification.Name {
    // MPMusicPlayerControllerによる通知をこちらで一旦引き受けることでタイミングを制御できるようにする
    static let DJYusakuPlayerQueueDidUpdate = Notification.Name("DJYusakuPlayerQueueDidUpdate")
    static let DJYusakuPlayerQueueNowPlayingSongDidChange = Notification.Name("DJYusakuPlayerQueueNowPlayingSongDidChange")
    static let DJYusakuPlayerQueuePlaybackStateDidChange = Notification.Name("DJYusakuPlayerQueuePlaybackStateDidChange")
}

class PlayerQueue{
    static let shared = PlayerQueue()
    let mpAppController = MPMusicPlayerController.applicationQueuePlayer
    
    private var items: [MPMediaItem] = []
    private var isQueueCreated: Bool = false
    private let playerDispatchQueue = DispatchQueue(label: "jp.yaplus.DJYusaku.PlayerQueue")
    
    // MPMusicPlayerApplicationController の indexOfNowPlayingItem の挙動が怪しいので自分で管理するための変数
    private(set) var indexOfNowPlayingSong: Int = 0
    
    private init(){
        mpAppController.repeatMode = MPMusicRepeatMode.all
        NotificationCenter.default.addObserver(self, selector: #selector(handleNowPlayingItemDidChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackStateDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }
    
    @objc func handleNowPlayingItemDidChange(notification: NSNotification){
        if mpAppController.indexOfNowPlayingItem == 0 {
            indexOfNowPlayingSong = 0
        } else {
            indexOfNowPlayingSong += 1  // FIXME: 連打するとバグる
        }
        
        NotificationCenter.default.post(name: .DJYusakuPlayerQueueNowPlayingSongDidChange, object: nil)
    }
    
    @objc func handlePlaybackStateDidChange(notification: NSNotification){
        NotificationCenter.default.post(name: .DJYusakuPlayerQueuePlaybackStateDidChange, object: nil)
    }
    
    private func create(with song : Song, completion: (() -> (Void))? = nil) {
        playerDispatchQueue.sync { // 再生キューは同時に操作してはいけないため、同期処理を強制する
            self.mpAppController.setQueue(with: [song.id])
            self.mpAppController.prepareToPlay() { [unowned self] error in
                guard error == nil else { return }
                self.mpAppController.play() // 自動再生する
                self.mpAppController.perform(queueTransaction: { _ in }, completionHandler: { [unowned self] queue, _ in
                    self.items = queue.items
                })
            }
            self.isQueueCreated = true
            if let completion = completion { completion() }
            NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil)
        }
    }

    private func insert(after index: Int, with song : Song, completion: (() -> (Void))? = nil){
        playerDispatchQueue.sync { // 再生キューは同時に操作してはいけないため、同期処理を強制する
            mpAppController.perform(queueTransaction: { mutableQueue in
                let descripter = MPMusicPlayerStoreQueueDescriptor(storeIDs: [song.id])
                let insertItem = mutableQueue.items.count == 0 ? nil : mutableQueue.items[index]
                mutableQueue.insert(descripter, after: insertItem)
            }, completionHandler: { [unowned self] queue, error in
                guard (error == nil) else { return } // TODO: 追加ができなかった時の処理
                self.items = queue.items
                if let completion = completion { completion() }
                NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil)
            })
        }
    }
    
    func remove(at index: Int, completion: (() -> (Void))? = nil) {
        playerDispatchQueue.sync { // 再生キューは同時に操作してはいけないため、同期処理を強制する
            mpAppController.perform(queueTransaction: {mutableQueue in
                mutableQueue.remove(mutableQueue.items[index])
            }, completionHandler: { [unowned self] queue, error in
                guard (error == nil) else { return } // TODO: 削除ができなかった時の処理
                self.items = queue.items
                if let completion = completion { completion() }
                NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil)
            })
        }
    }
    
    func add(with song : Song, completion: (() -> (Void))? = nil) {
        // TODO: トランザクション処理
        
        if !isQueueCreated { // キューが初期化されていないとき
            self.create(with: song, completion: completion)
        } else {            // 既にキューが作られているとき
            self.insert(after: items.count - 1, with: song, completion: completion)
        }
    }
    
    func count() -> Int {
        return items.count
    }
    
    func get(at index: Int) -> MPMediaItem? {
        guard index >= 0 && self.count() > index else { return nil }
        return items[index]
    }
    
}
