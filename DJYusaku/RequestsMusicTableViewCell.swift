//
//  RequestsMusicTableViewCell.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/16.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class RequestsMusicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var nowPlayingIndicator: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // アートワーク画像を角丸にする
        artwork.layer.cornerRadius = artwork.frame.size.width * 0.05
        artwork.clipsToBounds = true
        
        // アイコン画像を円形にする
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.5
        profileImageView.clipsToBounds = true
        
        self.animateNowPlayingIndicatior()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.animateNowPlayingIndicatior()
    }
    
    // インジケータを点滅させる
    func animateNowPlayingIndicatior() {
        UIView.transition(with: self.nowPlayingIndicator, duration: 1.0, options: [.repeat, .autoreverse, .beginFromCurrentState], animations: {
            self.nowPlayingIndicator.alpha = 0.05
        }) { _ in
            self.nowPlayingIndicator.alpha = 1.0
        }
    }
}
