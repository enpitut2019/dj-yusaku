//
//  MCConnecterDelegate.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/02.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import MultipeerConnectivity


protocol MCConnecterDelegate: class {

    // データを受け取ったとき
    func mcConnecter(didReceiveData data: Data, from peerID: MCPeerID)

    // 接続可能なピアが見つかったとき
    func mcConnecter(connectableDevicesChanged devices: [MCPeerID])
}
