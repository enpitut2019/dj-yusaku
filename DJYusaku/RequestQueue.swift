//
//  RequestQueue.swift
//  DJYusaku
//
//  Created by Yuu Ichikawa on 2019/10/24.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import UIKit

//Notification.Nameをどこに書けばいいかまだ決まっていない
extension Notification.Name {
    static let sendRequestName = Notification.Name("sendRequestName")
}

class RequestQueue{
    private init(){}
    
    static let shared = RequestQueue()
    
    private var requests : [MusicDataModel] = []
    // TODO: requestsの中身を追加する関数と消去する関数
    
    //requestsの中身を追加
    func addRequest(musicDataModel: MusicDataModel){
        requests.append(musicDataModel)
        //送る相手を指定していないため要修正
        NotificationCenter.default.post(name: .sendRequestName, object: nil)
    }
    
    //requestsの中身を削除
    func deleteRequest(indexPath: Int){
        requests.remove(at: indexPath)
    }
    
    //requestsの中身をカウントする
    func countRequests() -> Int {
        return requests.count
    }
    
    //requestsの中身を取得する
    func getRequest(indexPath: Int) -> MusicDataModel {
        return requests[indexPath]
    }
}
