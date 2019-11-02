//
//  RequestQueue.swift
//  DJYusaku
//
//  Created by Yuu Ichikawa on 2019/10/24.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer


extension Notification.Name {
    static let requestQueueToRequestsVCName = Notification.Name("requestQueueToRequestsVCName")
}

class RequestQueue{
    private init(){}
    static let shared = RequestQueue()
    
    // MARK: player関連の処理
    
    let mpAppController = MPMusicPlayerController.applicationQueuePlayer
    
    func insertMusicPlayerControllerQueue(songID : String){

        if (mpAppController.nowPlayingItem != nil){
            // FIXME: 一度キューを空にしたつもりでもnowPlayingItemはnilにならない
            mpAppController.perform(queueTransaction: { mutableQueue in
                let descripter = MPMusicPlayerStoreQueueDescriptor(storeIDs: [songID])

                mutableQueue.insert(descripter, after: mutableQueue.items.last)
            }, completionHandler: { queue, error in
                if (error != nil){
                    // TODO: キューへの追加ができなかった時の処理を記述
                }
            })
        } else {
            let descripter = MPMusicPlayerStoreQueueDescriptor(storeIDs: [songID])
            mpAppController.setQueue(with: descripter)
            mpAppController.play()

        }
    }
        
    
    

   // MARK: requests関連の処理
    
    private var requests : [MusicDataModel] = [] {
        // requestsを監視、変更後に実行する
        didSet {
            // requestsが追加されたらRequestsVCに通知する
            if requests.count > oldValue.count {
                let title  = requests[requests.count - 1].title
                let songID = requests[requests.count - 1].songID
                NotificationCenter.default.post(name: .requestQueueToRequestsVCName, object: nil, userInfo: ["title": title, "songID": songID])
            }
        }
    }
    // requestsの中身を追加する
    func addRequest(request: MusicDataModel){
        requests.append(request)
    }
    
    // requestsの中身を削除する
    func removeRequest(index: Int){
        requests.remove(at: index)
    }
    
    // requestsの中身をカウントする
    func countRequests() -> Int {
        return requests.count
    }
    
    // requestsの中身を取得する
    func getRequest(index: Int) -> MusicDataModel {
        return requests[index]
    }

}
