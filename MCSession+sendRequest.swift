//
//  MCSession+sendRequest.swift
//  DJYusaku
//
//  Created by leney on 2019/11/07.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import MultipeerConnectivity

extension MCSession{
    func sendRequest(_ data: Data, toPeers peerIDs: [MCPeerID], with mode: MCSessionSendDataMode, completion: (() -> (Void))? = nil) {
        do {
            try self.send(data, toPeers: peerIDs, with: mode)
        }
        catch {
            print(error)
        }
    }
}

