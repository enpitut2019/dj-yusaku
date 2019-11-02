//
//  MusicTableViewCell.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/12.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class SearchMusicTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    var song : Song!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // アートワーク画像を角丸にする
        artwork.layer.cornerRadius = artwork.frame.size.width * 0.05
        artwork.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //+ボタンを押したらRequestsViewControllerに曲を追加する
    @IBAction func sendRequest(_ sender: Any) {
        //ボタンを連続で押させないようにする
        button.isEnabled = false
        
        PlayerQueue.shared.add(with: song) {
            // TODO: リクエストが完了した旨をユーザーに通知する
        }
    }
}
