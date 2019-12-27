//
//  ListenerConnectableDJsTableViewCell.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/06.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class ListenerConnectableDJsTableViewCell: UITableViewCell {

    @IBOutlet weak var djName: UILabel!
    @IBOutlet weak var djImageView: UIImageView!
    @IBOutlet weak var numberOfParticipants: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // アイコン画像を円形にする
        djImageView.layer.cornerRadius = djImageView.frame.size.height * 0.5
        djImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
