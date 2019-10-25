//
//  MusicTableViewCell.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/12.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class SearchMusicTableViewCell: UITableViewCell {
    var requests = RequestQueue.shared
    // TODO: TableViewCellとアウトレット接続しているけど未使用
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // アートワーク画像を角丸にする
        artwork.layer.cornerRadius = artwork.frame.size.width * 0.05
        artwork.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func musicSelected(_ sender: Any) {
//        requests.music.append(MusicDataModel(title: title.text, artist: artist.text, artworkUrl: artwork))
    }
}
