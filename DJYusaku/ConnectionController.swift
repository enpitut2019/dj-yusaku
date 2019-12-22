//
//  ConnectionController.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/06.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension Notification.Name{
    static let DJYusakuConnectionControllerNowPlayingSongDidChange = Notification.Name("DJYusakuConnectionControllerNowPlayingSongDidChange")
    static let DJYusakuPeerConnectionStateDidUpdate = Notification.Name("DJYusakuPeerConnectionStateDidUpdate")
    static let DJYusakuDisconnectedFromDJ =
        Notification.Name("DJYusakuDisconnectedFromDJ")
}

class ConnectionController: NSObject {
    static let shared = ConnectionController()
    
    public weak var delegate: ConnectionControllerDelegate?
    
    let serviceType = "djyusaku"
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    private(set) var isInitialized = false
    
    var isDJ: Bool? = nil
    
    // Listener 用
    var connectableDJs: [MCPeerID] = []
    var connectableDJNameCorrespondence : [MCPeerID:(String, String?)] = [:]    // TODO: 消えなさい
    var connectedDJ: MCPeerID? = nil
    
    var receivedSongs: [Song] = []
    
    var peerProfileCorrespondence: [MCPeerID:PeerProfile] = [:]
    
    func initialize() {
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self

        self.browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
        self.browser.delegate = self
        
        self.isInitialized = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleViewWillEnterForeground), name: .DJYusakuRequestVCWillEnterForeground, object: nil)
    }
    
    @objc func handleViewWillEnterForeground() {
        guard let connectedDJ = connectedDJ else { return }
        self.browser.invitePeer(connectedDJ, to: ConnectionController.shared.session, withContext: nil, timeout: 10.0)
    }

    func startBrowse() {
        self.browser.startBrowsingForPeers()
    }
    
    func stopBrowse() {
        self.browser.stopBrowsingForPeers()
    }
    
    func disconnect() {
        self.session.disconnect()
        self.connectedDJ = nil
        
    }
    
    func startDJ(displayName: String, iconUrlString: String? = nil) {
        self.disconnect()
        var info = ["name": displayName]
        
        if iconUrlString != nil {
            info["imageUrl"] = iconUrlString
        }
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: info, serviceType: self.serviceType)
        self.advertiser.delegate = self
        
        self.isDJ = true
        self.advertiser.startAdvertisingPeer()
    }
    
    func startListener(selectedDJ: MCPeerID) {
        if selectedDJ != self.connectedDJ {
            self.disconnect()
        }
        self.browser.invitePeer(selectedDJ, to: session, withContext: nil, timeout: 10.0)
        self.connectedDJ = selectedDJ
        self.isDJ = false
        if self.advertiser != nil {
            self.advertiser.stopAdvertisingPeer()
        }
    }
    
}

// MARK: - MCSessionDelegate

extension ConnectionController: MCSessionDelegate {
    // 接続ピアの状態が変化したとき呼ばれる
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("Peer \(peerID.displayName) is not connected.")
            break
        case .connecting:
            print("Peer \(peerID.displayName) is connecting...")
            break
        case .connected:
            NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
            
            // プロフィールが設定されていれば他のピアに送信する
            if let profile = DefaultsController.shared.profile {
                let data = try! JSONEncoder().encode(profile)
                let messageData = try! JSONEncoder().encode(MessageData(desc:  MessageData.DataType.peerProfile, value: data))
                self.session.sendRequest(messageData, toPeers: [peerID], with: .unreliable)
            }
            
            print("Peer \(peerID.displayName) is connected.")
            if ConnectionController.shared.isDJ! {   // DJが新しい子機と接続したとき
                var songs: [Song] = []
                for i in 0..<PlayerQueue.shared.count() {
                    songs.append(PlayerQueue.shared.get(at: i)!)
                }
                let songsData = try! JSONEncoder().encode(songs)
                let messageData = try! JSONEncoder().encode(MessageData(desc:  MessageData.DataType.requestSongs, value: songsData))
                do {
                    try self.session.send(messageData, toPeers: [peerID], with: .unreliable)
                } catch let error {
                    print(error)
                }
                //注意: これはPlayerQueueで実装しているNotification.Nameです
                NotificationCenter.default.post(name:
                    .DJYusakuPlayerQueueNowPlayingSongDidChange, object: nil)
            }
            break
        default:
            break
        }
    }
    
    // 他のピアによる send を受け取ったとき呼ばれる
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("\(peerID)から \(String(data: data, encoding: .utf8)!)を受け取りました")
        
        let messageData = try! JSONDecoder().decode(MessageData.self, from: data)
        if self.isDJ! { // DJがデータを受け取ったとき
            switch messageData.desc {
            case MessageData.DataType.requestSong:
                let song = try! JSONDecoder().decode(Song.self, from: messageData.value)
                PlayerQueue.shared.add(with: song)
            case MessageData.DataType.peerProfile:
                let profile = try! JSONDecoder().decode(PeerProfile?.self, from: messageData.value)
                self.peerProfileCorrespondence[peerID] = profile
                NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
            default:
                break
            }
        } else { // リスナーがデータを受け取ったとき
            switch messageData.desc {
                case MessageData.DataType.requestSongs:
                    let songs = try! JSONDecoder().decode([Song].self, from: messageData.value)
                    receivedSongs = songs
                    NotificationCenter.default.post(name: .DJYusakuPlayerQueueDidUpdate, object: nil)
                case MessageData.DataType.nowPlaying:
                    let nowPlaying = try! JSONDecoder().decode(Song.self, from: messageData.value)
                    NotificationCenter.default.post(name: .DJYusakuConnectionControllerNowPlayingSongDidChange, object: nil, userInfo: ["song": nowPlaying as Any])
                case MessageData.DataType.peerProfile:
                    let profile = try! JSONDecoder().decode(PeerProfile?.self, from: messageData.value)
                    self.peerProfileCorrespondence[peerID] = profile
                    NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
                default:
                    break
            }
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

extension ConnectionController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension ConnectionController: MCNearbyServiceBrowserDelegate {

    // 接続可能なピアが見つかったとき
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        self.connectableDJs.append(peerID)
        
        // TODO: DJ名にinfoを使うのは非互換な変更のため、以下のようにして互換性を保つ
        if let info = info {
            self.connectableDJNameCorrespondence[peerID] = (info["name"], info["imageUrl"]) as? (String, String?)
        } else {
            self.connectableDJNameCorrespondence[peerID] = (peerID.displayName, nil)
        }

        self.delegate?.connectionController(didChangeConnectableDevices: self.connectableDJs)
    }

    // 接続可能なピアが消えたとき
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.connectableDJs = connectableDJs.filter { $0 != peerID }
        
        self.delegate?.connectionController(didChangeConnectableDevices: self.connectableDJs)
    }
    
    /// エラーが起こったとき
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    }

}
