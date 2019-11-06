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
    // データを受け取ったとき
    func connectionController(didReceiveData data: Data, from peerID: MCPeerID)

    // 接続可能なピアが見つかったとき
    func connectionController(connectableDevicesChanged devices: [MCPeerID])
}
