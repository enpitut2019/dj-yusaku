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
    static let DJYusakuPlayerQueueDidUpdate = Notification.Name("DJYusakuPlayerQueueDidUpdate")
    static let DJYusakuPlayerQueueDidNowPlayingSongDidChange = Notification.Name("DJYusakuPlayerQueueDidNowPlayingSongDidChange")
}

class PlayerQueue{
    static let shared = PlayerQueue()
    let mpAppController = MPMusicPlayerController.applicationQueuePlayer
    private var items: [MPMediaItem] = []
    private var isQueueCreated: Bool = false
    
    // MPMusicPlayerApplicationController の indexOfNowPlayingItem の挙動が怪しいので自分で管理するための変数
    private(set) var indexOfNowPlayingSong: Int = 0
    
    private init(){
        mpAppController.repeatMode = MPMusicRepeatMode.all
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayingItemDidChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    @objc func handlePlayingItemDidChange(notification: NSNotification){
        if mpAppController.indexOfNowPlayingItem == 0 {
            indexOfNowPlayingSong = 0
        } else {
            indexOfNowPlayingSong += 1  // FIXME: 連打するとバグる
        }
        
        NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidNowPlayingSongDidChange, object: nil)
    }
    
    private func create(with song : Song, completion: (() -> (Void))? = nil) {
        self.mpAppController.setQueue(with: [song.id])
        self.mpAppController.play()    // 自動再生にするときはself.mpAppController.play()を呼ぶ
        self.isQueueCreated = true
        mpAppController.perform(queueTransaction: { _ in }, completionHandler: { [unowned self] queue, _ in
            self.items = queue.items
        })
        if let completion = completion { completion() }
        NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil)
    }

    private func insert(after index: Int, with song : Song, completion: (() -> (Void))? = nil){
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
    
    func remove(at index: Int, completion: (() -> (Void))? = nil) {
        mpAppController.perform(queueTransaction: {mutableQueue in
            mutableQueue.remove(mutableQueue.items[index])
        }, completionHandler: { [unowned self] queue, error in
            guard (error == nil) else { return } // TODO: 削除ができなかった時の処理
            self.items = queue.items
            if let completion = completion { completion() }
            NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil)
        })
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
        guard self.count() != 0 && self.count() > index else { return nil }
        return items[index]
    }
    
}
