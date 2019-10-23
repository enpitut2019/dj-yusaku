//
//  Artwork.swift
//  DJYusaku
//
//  Created by leney on 2019/10/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import Foundation

class Artwork {
    
    //お試しのシングルトンのキャッシュ、あとで消す
    //static let testCache = Artwork()
    
    //あとでprivateに直す
    static var imageCache = NSCache<AnyObject, AnyObject>()
    
//    private init() {
//        //write initialize code
//    }
    
    // 任意のサイズのアートワーク用URLを生成(SearchViewControllerから移動)するクラス関数
    static func artworkUrl(urlString: String, width: Int, height: Int) -> URL {
        let replaced = urlString.replacingOccurrences(of: "{w}", with: "\(width)")
                                .replacingOccurrences(of: "{h}", with: "\(height)")
        return URL(string: replaced)!
    }
    // URLを受け取ってキャッシュに保存してUIImageに変換する
    static func cacheProcessing(url: URL) -> UIImage? {
        var returnUIImage: UIImage?
        if let imageData = imageCache.object(forKey: url as AnyObject){
            returnUIImage = UIImage(data: imageData as! Data)
        }
         else {
            let downloadTask = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print(error)
                    return
            }
                imageCache.setObject(data as AnyObject, forKey: url as AnyObject)
                returnUIImage = UIImage(data: data!)
            }
            downloadTask.resume()
        }
        return returnUIImage
    }
}
