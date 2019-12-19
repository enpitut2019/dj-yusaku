//
//  MessageData.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

struct MessageData : Codable {
    var desc : MessageData.DataType // データの種類
    var value: Data             // JSONデータ
    
    enum DataType: Int, Codable {
        case nowPlaying
        case requestSong
        case requestSongs
        case peerProfile
    }
}
