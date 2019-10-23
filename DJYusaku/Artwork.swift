//
//  Artwork.swift
//  DJYusaku
//
//  Created by leney on 2019/10/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation

final class Artwork: NSCache<AnyObject, AnyObject> {
    
    //お試しのシングルトンのキャッシュ、あとで消す
    static let testCache = Artwork()
    
    //お試しのキャッシュ、あとで消す
    //static let imageCache = NSCache<AnyObject, AnyObject>()
    
    private override init() {
        //write initialize code
    }
    
    // 任意のサイズのアートワーク用URLを生成(SearchViewControllerから移動)するクラス関数
    static func artworkUrl(urlString: String, width: Int, height: Int) -> URL {
        let replaced = urlString.replacingOccurrences(of: "{w}", with: "\(width)")
                                .replacingOccurrences(of: "{h}", with: "\(height)")
        return URL(string: replaced)!
    }
}
