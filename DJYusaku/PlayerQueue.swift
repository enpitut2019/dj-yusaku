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
        // Queueに勝手にnowPlayingItemが積まれているので、Repeatを殺して対策
        mpAppController.repeatMode = MPMusicRepeatMode.none
    }

    func insert(after index: Int, with song : MusicDataModel){
        mpAppController.perform(queueTransaction: { mutableQueue in
            let descripter = MPMusicPlayerStoreQueueDescriptor(storeIDs: [song.songID])
            mutableQueue.insert(descripter, after: mutableQueue.items[index])
        }, completionHandler: { [unowned self] queue, error in
            guard (error == nil) else { return } // TODO: キューへの追加ができなかった時の処理を記述
            self.requestItems.insert(song, at: index+1)
            NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil, userInfo: ["title":song.title])
        })
    }
    
    func remove(at index: Int) {
        guard (mpAppController.nowPlayingItem != nil) else { return }
        mpAppController.perform(queueTransaction: { mutableQueue in
            mutableQueue.remove(mutableQueue.items[index])
        }, completionHandler: { [unowned self] queue, error in
            guard (error == nil) else { return } // TODO: キューでの削除ができなかった時の処理を記述
            let removedItem = self.requestItems[index]
            NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil, userInfo: ["title":removedItem.title])
            self.requestItems.remove(at: index)
        })
    }
    
    func add(with song : MusicDataModel) {
        // TODO: トランザクション処理
        
        if !isQueueCreated { // キューが初期化されていないとき
            self.mpAppController.setQueue(with: [song.songID])
            self.mpAppController.play()
            self.requestItems.append(song)
            NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil, userInfo: ["title":song.title])
            isQueueCreated = true
        } else {            // 既にキューが作られているとき
            self.insert(after: requestItems.count - 1, with: song)
        }
        
        // リクエストが完了した旨のAlertを表示
        
    }
    
    func count() -> Int {
        return requestItems.count
    }
    
    func get(at index: Int) -> MusicDataModel? {
        guard self.count() != 0 && self.count() > index else { return nil }
        return requestItems[index]
    }
    
}
