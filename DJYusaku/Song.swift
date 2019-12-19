//
//  Song.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/11.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

struct Song : Codable {
    var title:  String      // 曲名
    var artist: String      // アーティスト名
    var artworkUrl: URL     // 画像アートワーク
    var id : String         // 曲の Store ID
    var index : Int?        // RequestViewにおける曲の再生位置
    
    var iconURL: URL?       // アイコン画像のURL(なくても良い)
    
    init(title: String, artist: String, artworkUrl: URL, id: String, index : Int? = nil, iconURL: URL? = nil){
        self.title      = title
        self.artist     = artist
        self.artworkUrl = artworkUrl
        self.id         = id
        self.index      = index
        self.iconURL    = iconURL
    }
}
