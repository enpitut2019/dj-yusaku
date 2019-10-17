//
//  MusicDataModel.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/11.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

struct MusicDataModel {
    var title:  String // 曲名
    var artist: String // アーティスト名
    var artwork: UIImage // 画像アートワーク

    init(title: String, artist: String, artwork: UIImage){
        self.title   = title
        self.artist  = artist
        self.artwork = artwork
    }
}
