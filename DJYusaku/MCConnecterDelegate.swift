//
//  MCConnecterDelegate.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/02.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import MultipeerConnectivity

///
/// multiPeer(didRecieveData: Data, ofType: UInt32)
/// multiPeer(connectedDevicesChanged: [String])
public protocol MCConnecterDelegate: class {

    /// didReceiveData: delegate runs on receiving data from another peer
    func mcConnecter(didReceiveData data: Data, ofType type: UInt32)

    /// connectedDevicesChanged: delegate runs on connection/disconnection event in session
    func mcConnecter(connectedDevicesChanged devices: [String])

    func mcConnecter(connectableDevicesChanged devices: [MCPeerID], browser: MCNearbyServiceBrowser)
}
