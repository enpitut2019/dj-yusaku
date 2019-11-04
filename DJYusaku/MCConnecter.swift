//
//  MCConnecter.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/02.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCConnecter: NSObject {
    static let shared = MCConnecter()
    
    public weak var delegate: MCConnecterDelegate?
    
    let serviceType = "djyusaku"
    
    var peerID :MCPeerID!
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!

    var initialized = false
    var connectableDJs: [MCPeerID] = []
    
    var isParent: Bool!
    
    func initialize(isParent: Bool, displayName: String) {
        self.initialized = true
        self.isParent = isParent
        
        self.peerID = MCPeerID(displayName: displayName)
        self.session = MCSession(peer: self.peerID)
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: self.serviceType)
        advertiser.delegate = self

        browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
        browser.delegate = self
    }
    
    func parent() -> Bool {
        return self.isParent
    }
    
    func startAdvertise() {
        advertiser.startAdvertisingPeer()
    }
    
    func startBrowse() {
        browser.startBrowsingForPeers()
    }
    
    func stopBrowse() {
        browser.stopBrowsingForPeers()
    }
    
}

// MARK: - MCSessionDelegate
extension MCConnecter: MCSessionDelegate {
    // 接続ピアの状態が変化したとき呼ばれる
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            print("Peer \(peerID.displayName) is connected.")
        } else {
            print("Peer \(peerID.displayName) is not connected.")
        }
    }
    
    // 他のピアによる send を受け取ったとき呼ばれる
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("recieved Data: \(String(data: data, encoding: .utf8)!)")
        DispatchQueue.main.async {
            self.delegate?.mcConnecter(didReceiveData: data, from: peerID)
        }
    }
    
    // 他のピアによる sendStream を受け取ったとき呼ばれる
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print(#function)
        // Do nothing
    }
    
    // 他のピアによる sendResource を受け取ったとき呼ばれる
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print(#function)
        // Do nothing
    }
    
    // 他のピアによる sendResource を受け取ったとき呼ばれる
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print(#function)
        // Do nothing
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MCConnecter: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MCConnecter: MCNearbyServiceBrowserDelegate {

    // 接続可能なピアが見つかったとき
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        self.connectableDJs.append(peerID)
            
        print("browser: connectable  DJ is found")
            
        DispatchQueue.main.async {
            self.delegate?.mcConnecter(connectableDevicesChanged: self.connectableDJs)
        }
    }

    // 接続可能なピアが消えたとき
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("browser: connectable  DJ is lost")
        
        connectableDJs = connectableDJs.filter { $0 != peerID }
        
        DispatchQueue.main.async {
                self.delegate?.mcConnecter(connectableDevicesChanged: self.connectableDJs)
        }
    }

    /// エラーが起こったとき
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    }

}
