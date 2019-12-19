//
//  PeerProfile.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/12/19.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

struct PeerProfile : Codable {
    var name : String           // Twitter上の名前(name)
    var imageUrl: URL           // アイコン画像のURL(profile_image_url_https)
    
    init(name: String, imageUrl: URL){
        self.name     = name
        self.imageUrl = imageUrl
    }
}
