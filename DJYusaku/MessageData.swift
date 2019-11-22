//
//  MessageData.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

struct MessageData : Codable {
    var desc:  String // 説明
    var value: Data   // JOSNデータ
}

