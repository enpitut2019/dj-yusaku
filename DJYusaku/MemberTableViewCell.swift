//
//  MemberTableViewCell.swift
//  DJYusaku
//
//  Created by Yuu Ichikawa on 2019/11/23.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var peerImageView: UIImageView!
    @IBOutlet weak var peerName: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // アイコン画像を円形にする
        peerImageView.layer.cornerRadius = peerImageView.frame.size.height * 0.5
        peerImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
