//
//  MusicDataModel.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/11.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class MusicDataModel : NSObject {
    var title:  String // 曲名
    var artist: String // アーティスト名

    init(title: String, artist: String){
        self.title  = title
        self.artist = artist
    }
}
