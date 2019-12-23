//
//  Artwork.swift
//  DJYusaku
//
//  Created by leney on 2019/10/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import Foundation

class CachedImage {
    
    private static var imageCache = NSCache<AnyObject, AnyObject>()

    static func url(urlString: String, width: Int, height: Int) -> URL {
        let replaced = urlString.replacingOccurrences(of: "{w}", with: "\(width)")
                                .replacingOccurrences(of: "{h}", with: "\(height)")
        return URL(string: replaced)!
    }
    
    static func fetch(url: URL) -> UIImage? {
        var artworkImage: UIImage? = nil
        if let imageData = imageCache.object(forKey: url as AnyObject){
            artworkImage = UIImage(data: imageData as! Data)
            return artworkImage
        }
        do {
            let imageData = try Data(contentsOf: url)
            imageCache.setObject(imageData as AnyObject, forKey: url as AnyObject)
            artworkImage = UIImage(data: imageData)
        } catch {
            // TODO: 画像が取得できなかった際のエラーハンドリング
        }
        return artworkImage
    }
}
