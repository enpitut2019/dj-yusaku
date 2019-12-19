//
//  MessageData.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

struct MessageData : Codable {
    var desc : MessageData.Name // 説明
    var value: Data   // JOSNデータ
    
    enum Name: Int, Codable {
        case nowPlaying
        case requestSong
        case requestSongs
        case iconURL
    }
}
