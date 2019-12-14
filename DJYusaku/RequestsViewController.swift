//
//  RequestsViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/05.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer

extension Notification.Name {
    static let DJYusakuRequestVCWillEnterForeground = Notification.Name("DJYusakuRequestVCWillEnterForeground")
}
class RequestsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var playerControllerView: UIVisualEffectView!
    
    static private var isViewAppearedAtLeastOnce: Bool = false
    static private var indexOfNowPlayingItemOnListener: Int = 0
    
    private let cloudServiceController = SKCloudServiceController()
    private let defaultArtwork : UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        // コントローラの角を丸くする
        playerControllerView.layer.cornerRadius = playerControllerView.frame.size.width * 0.05
        playerControllerView.clipsToBounds = true

        let footerView = UIView()
        footerView.frame.size.height = 100
        tableView.tableFooterView = footerView // 空のセルの罫線を消す
        
        // Apple Musicライブラリへのアクセス許可の確認
        SKCloudServiceController.requestAuthorization { status in
            guard status == .authorized else { return }
            // Apple Musicの曲が再生可能か確認
            self.cloudServiceController.requestCapabilities { (capabilities, error) in
                guard error == nil && capabilities.contains(.musicCatalogPlayback) else { return }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequestsDidUpdate), name: .DJYusakuPlayerQueueDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNowPlayingItemDidChangeOnDJ), name: .DJYusakuPlayerQueueNowPlayingSongDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackStateDidChange), name: .DJYusakuPlayerQueuePlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNowPlayingItemDidChangeOnListener), name: .DJYusakuConnectionControllerNowPlayingSongDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleViewWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !RequestsViewController.isViewAppearedAtLeastOnce {  // 初回だけ表示する画面遷移に使う
            // 初回にはWelcomeViewをモーダルを表示
            let storyboard: UIStoryboard = self.storyboard!
            let welcomeNavigationController = storyboard.instantiateViewController(withIdentifier: "WelcomeNavigation")
            welcomeNavigationController.isModalInPresentation = true
            self.present(welcomeNavigationController, animated: true)
        }
        RequestsViewController.isViewAppearedAtLeastOnce = true
        
        // TableViewの表示を更新する
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func handleRequestsDidUpdate(){
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    @objc func handleNowPlayingItemDidChangeOnDJ(){
        guard let nowPlayingSong = PlayerQueue.shared.getNowPlaying() else {return}
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        guard ConnectionController.shared.session.connectedPeers.count != 0 else { return }
        
        let nowPlayingData = try! JSONEncoder().encode(nowPlayingSong)
        let messageData = try! JSONEncoder().encode(MessageData(desc: MessageData.Name.nowPlaying, value: nowPlayingData))
        do {
            try ConnectionController.shared.session.send(messageData, toPeers: ConnectionController.shared.session.connectedPeers, with: .unreliable)
        } catch let error {
            print(error)
        }
    }
    
    // （リスナーのとき）NowPlayingItemが変わったとき呼ばれる
    @objc func handleNowPlayingItemDidChangeOnListener(notification: NSNotification){
        guard let song = notification.userInfo!["song"] as? Song else { return }
        RequestsViewController.self.indexOfNowPlayingItemOnListener = song.index ?? 0
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func handlePlaybackStateDidChange(notification: NSNotification) {
        switch PlayerQueue.shared.mpAppController.playbackState {
        case .playing:
            playButton.setImage(UIImage(systemName: "pause"), for: UIControl.State.normal)
        case .paused, .stopped:
            playButton.setImage(UIImage(systemName: "play"), for: UIControl.State.normal)
        default:
            break
        }
    }
    
    @objc func handleViewWillEnterForeground() {
        guard ConnectionController.shared.isDJ != nil else { return }
        if !ConnectionController.shared.isDJ {
            NotificationCenter.default.post(
                name: .DJYusakuRequestVCWillEnterForeground,
                object: nil
            )
        }
    }
    
    @IBAction func playButton(_ sender: Any) {
        switch PlayerQueue.shared.mpAppController.playbackState {
        case .playing:          // 再生中なら停止する
            PlayerQueue.shared.mpAppController.pause()
        case .paused, .stopped: // 停止中なら再生する
            PlayerQueue.shared.mpAppController.play()
        default:
            break
        }
    }
    
    @IBAction func skipButton(_ sender: Any) {
        PlayerQueue.shared.mpAppController.skipToNextItem()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
    }
}

// MARK: - UITableViewDataSource

extension RequestsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard ConnectionController.shared.isDJ != nil else { return 0 }
        if ConnectionController.shared.isDJ {
            return PlayerQueue.shared.count()
        } else {
            return ConnectionController.shared.receivedSongs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsMusicTableViewCell", for: indexPath) as! RequestsMusicTableViewCell
        var song: Song
        if ConnectionController.shared.isDJ {
            guard let queueSong = PlayerQueue.shared.get(at: indexPath.row) else { return cell }
            song = queueSong
        } else {
            song = ConnectionController.shared.receivedSongs[indexPath.row]
        }
        
        let indexOfNowPlayingItem = ConnectionController.shared.isDJ
                                  ? PlayerQueue.shared.mpAppController.indexOfNowPlayingItem
                                  : RequestsViewController.self.indexOfNowPlayingItemOnListener
        cell.title.text    = song.title
        cell.artist.text   = song.artist
        cell.nowPlayingIndicator.isHidden = indexOfNowPlayingItem != indexPath.row
        
        DispatchQueue.global().async {
            let image = Artwork.fetch(url: song.artworkUrl)
            DispatchQueue.main.async {
                cell.artwork.image = image  // 画像の取得に失敗していたらnilが入ることに注意
                cell.artwork.setNeedsLayout()
            }
        }
        if (indexPath.row < indexOfNowPlayingItem) {
            cell.title.alpha    = 0.3
            cell.artist.alpha   = 0.3
            cell.artwork.alpha  = 0.3
        } else {
            cell.title.alpha    = 1.0
            cell.artist.alpha   = 1.0
            cell.artwork.alpha  = 1.0
        }
        
        return cell
    }
    
    // 編集・削除機能を無効にする
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}


