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
    @IBOutlet weak var numberOfParticipantsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // アイコン画像を円形にする
        djImageView.layer.cornerRadius = djImageView.frame.size.height * 0.5
        djImageView.clipsToBounds = true
        
        // 参加人数表示の見た目を設定（角丸・影・境界線など）
        numberOfParticipantsLabel.layer.cornerRadius = numberOfParticipantsLabel.frame.size.height * 0.5
        numberOfParticipantsLabel.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
