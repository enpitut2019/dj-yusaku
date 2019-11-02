//
//  Song.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/11.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

struct Song {
    var title:  String      // 曲名
    var artist: String      // アーティスト名
    var artworkUrl: URL     // 画像アートワーク
    var id : String         // 曲の Store ID

    init(title: String, artist: String, artworkUrl: URL, id: String){
        self.title      = title
        self.artist     = artist
        self.artworkUrl = artworkUrl
        self.id         = id
    }
}
