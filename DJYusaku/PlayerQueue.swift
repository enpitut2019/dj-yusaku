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
}

class PlayerQueue{
    static let shared = PlayerQueue()
    let mpAppController = MPMusicPlayerController.applicationQueuePlayer
    private var requestItems: [MusicDataModel] = []
    private var isQueueCreated: Bool = false
    
    private init(){
        // Queueに新しい要素が追加されないようリピート再生を無効にしておく
        mpAppController.repeatMode = MPMusicRepeatMode.none
    }
    
    private func create(with song : MusicDataModel) {
        self.mpAppController.setQueue(with: [song.songID])
        self.requestItems.append(song)
        self.mpAppController.prepareToPlay()
        self.isQueueCreated = true
        NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil, userInfo: ["title":song.title])
    }

    private func insert(after index: Int, with song : MusicDataModel){
        
        mpAppController.perform(queueTransaction: { mutableQueue in
            let descripter = MPMusicPlayerStoreQueueDescriptor(storeIDs: [song.songID])
            let insertItem = mutableQueue.items.count == 0 ? nil : mutableQueue.items[index]
            mutableQueue.insert(descripter, after: insertItem)
        }, completionHandler: { [unowned self] queue, error in
            guard (error == nil) else { return } // TODO: 追加ができなかった時の処理
            self.requestItems.insert(song, at: index+1)
            print("YusakuTest", "After", self.requestItems[index].title, queue.items[index].title!)
            NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil, userInfo: ["title":song.title])
        })
    }
    
    func remove(at index: Int) {
        guard (mpAppController.nowPlayingItem != nil) else { return }
        mpAppController.perform(queueTransaction: { mutableQueue in
            mutableQueue.remove(mutableQueue.items[index])
        }, completionHandler: { [unowned self] queue, error in
            guard (error == nil) else { return } // TODO: 削除ができなかった時の処理
            let removedItem = self.requestItems[index]
            NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil, userInfo: ["title":removedItem.title])
            self.requestItems.remove(at: index)
        })
    }
    
    func add(with song : MusicDataModel) {
        // TODO: トランザクション処理
        
        if !isQueueCreated { // キューが初期化されていないとき
            self.create(with: song)
        } else {            // 既にキューが作られているとき
            self.insert(after: requestItems.count - 1, with: song)
        }
        
        // TODO: リクエストが完了した旨のAlertを表示
        
    }
    
    func count() -> Int {
        return requestItems.count
    }
    
    func get(at index: Int) -> MusicDataModel? {
        guard self.count() != 0 && self.count() > index else { return nil }
        return requestItems[index]
    }
    
}
