//
//  ConnectionControllerDelegate.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/06.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ConnectionControllerDelegate: class {
    // 接続可能なピアが見つかったとき
    func connectionController(didChangeConnectableDevices devices: [MCPeerID])
}
