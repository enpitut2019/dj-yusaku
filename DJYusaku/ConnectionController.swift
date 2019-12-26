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
    static let DJYusakuDisconnectedFromDJ = Notification.Name("DJYusakuDisconnectedFromDJ")
    static let DJYusakuUserStateDidUpdate =
        Notification.Name("DJYusakuUserStateDidUpdate")
}

class ConnectionController: NSObject {
    static let shared = ConnectionController()
    
    public weak var delegate: ConnectionControllerDelegate?
    
    private let serviceType = "djyusaku"
    
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    private(set) var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    private(set) var isInitialized = false
    
    private(set) var isDJ: Bool? = nil
    private(set) var connectedDJ: (peerID: MCPeerID, state: MCSessionState)? = nil
    
    var peerProfileCorrespondence: [MCPeerID:PeerProfile] = [:]
    
    var connectableDJs: [MCPeerID] = [] //  ListenerConnectionViewController用
    
    private(set) var receivedSongs: [Song] = [] // リスナー用
    
    func initialize() {
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self

        self.browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
        self.browser.delegate = self
        
        self.isInitialized = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleViewDidEnterBackground), name: .DJYusakuRequestVCDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleViewWillEnterForeground), name: .DJYusakuRequestVCWillEnterForeground, object: nil)
    }
    
    @objc func handleViewDidEnterBackground() {
        guard self.connectedDJ != nil else { return }
        self.session.disconnect()
    }
    
    @objc func handleViewWillEnterForeground() {
        guard let connectedDJ = self.connectedDJ else { return }
        self.browser.invitePeer(connectedDJ.peerID, to: self.session, withContext: nil, timeout: 10.0)
        self.connectedDJ!.state = .connected
    }

    func startAdvertise(displayName: String, imageUrl: URL?) {
        if self.advertiser != nil {
            self.advertiser.stopAdvertisingPeer()
        }
        let info = ["name":     displayName,
                    "imageUrl": imageUrl?.absoluteString ?? ""]
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: info, serviceType: self.serviceType)
        self.advertiser.delegate = self
        self.advertiser.startAdvertisingPeer()
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
    
    func startDJ() {
        self.isDJ = true
        self.disconnect()
        let profile = DefaultsController.shared.profile
        startAdvertise(displayName: profile.name, imageUrl: profile.imageUrl)
        NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
        NotificationCenter.default.post(name: .DJYusakuUserStateDidUpdate, object: nil)
    }
    
    func startListener(selectedDJ: MCPeerID) {
        PlayerQueue.shared.clearSongs()
        self.isDJ = false
        if selectedDJ != self.connectedDJ?.peerID {
            self.disconnect()
        }
        self.browser.invitePeer(selectedDJ, to: session, withContext: nil, timeout: 10.0)
        self.connectedDJ = (selectedDJ, .connected)
        if self.advertiser != nil {
            self.advertiser.stopAdvertisingPeer()
        }
        NotificationCenter.default.post(name: .DJYusakuUserStateDidUpdate, object: nil)
    }
    
}

// MARK: - MCSessionDelegate

extension ConnectionController: MCSessionDelegate {
    // 接続ピアの状態が変化したとき呼ばれる
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("Peer \(peerID.displayName) is disconnected.")
            NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
            if !self.isDJ! && peerID == self.connectedDJ?.peerID { // リスナーがDJを見失ったとき
                self.connectedDJ!.state = .notConnected
            }
            break
        case .connecting:
            print("Peer \(peerID.displayName) is connecting...")
            break
        case .connected:
            print("Peer \(peerID.displayName) is connected.")
            NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
            
            // 接続したらプロフィールを他のピアに送信する
            let data = try! JSONEncoder().encode(DefaultsController.shared.profile)
            let messageData = try! JSONEncoder().encode(MessageData(desc:  MessageData.DataType.peerProfile, value: data))
            self.session.sendRequest(messageData, toPeers: [peerID], with: .unreliable)
            
            if self.isDJ! {   // DJが新しい子機と接続したとき
                var songs: [Song] = []
                for i in 0..<PlayerQueue.shared.count() {
                    songs.append(PlayerQueue.shared.get(at: i)!)
                }
                let songsData = try! JSONEncoder().encode(songs)
                let messageData = try! JSONEncoder().encode(MessageData(desc:  MessageData.DataType.requestSongs, value: songsData))
                self.session.sendRequest(messageData, toPeers: [peerID], with: .unreliable)
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
                    let indexOfNowPlayingItem = try! JSONDecoder().decode(Int.self, from: messageData.value)
                    NotificationCenter.default.post(name: .DJYusakuConnectionControllerNowPlayingSongDidChange, object: nil, userInfo: ["indexOfNowPlayingItem": indexOfNowPlayingItem as Any])
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
        if !self.connectableDJs.contains(peerID) {
            self.connectableDJs.append(peerID)
        }
        
        self.peerProfileCorrespondence[peerID] = PeerProfile(name:     info!["name"]!,
                                                             imageUrl: URL(string: info!["imageUrl"]!))

        self.delegate?.connectionController(didChangeConnectableDevices: self.connectableDJs)
    }

    // 接続可能なピアが消えたとき
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.connectableDJs = self.connectableDJs.filter { $0 != peerID }
        
        self.delegate?.connectionController(didChangeConnectableDevices: self.connectableDJs)
    }
    
    /// エラーが起こったとき
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    }

}
