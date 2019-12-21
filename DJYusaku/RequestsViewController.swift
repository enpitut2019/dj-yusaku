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
    @IBOutlet weak var batterySaverButton: UIButton!

    @IBOutlet weak var playerControllerView: UIView!
    @IBOutlet weak var playButtonBackgroundView: UIView!
    
    static private var isViewAppearedAtLeastOnce: Bool = false
    static private var indexOfNowPlayingItemOnListener: Int = 0
    
    private let cloudServiceController = SKCloudServiceController()
    private let defaultArtwork : UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate   = self
        
        // 再生コントロールの見た目を設定（角丸・影・境界線など）
        playerControllerView.layer.cornerRadius = playerControllerView.frame.size.height * 0.5
        playerControllerView.layer.shadowColor   = CGColor(srgbRed: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        playerControllerView.layer.shadowOffset  = .zero
        playerControllerView.layer.shadowOpacity = 0.4
        playerControllerView.layer.borderColor = CGColor(srgbRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        playerControllerView.layer.borderWidth = 1

        playButtonBackgroundView.layer.cornerRadius = playButtonBackgroundView.frame.size.height * 0.5

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
        // スクロールを現在再生中の曲に移動する
        scrollToNowPlayingItem(animated: false)
    }
    
    @objc func handleRequestsDidUpdate(){
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    @objc func handleNowPlayingItemDidChangeOnDJ(){
        guard let nowPlayingSong = PlayerQueue.shared.getNowPlaying() else { return }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        guard ConnectionController.shared.session.connectedPeers.count != 0 else { return }
        
        let nowPlayingData = try! JSONEncoder().encode(nowPlayingSong)
        let messageData = try! JSONEncoder().encode(MessageData(desc: MessageData.DataType.nowPlaying, value: nowPlayingData))
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
            playButton.setImage(UIImage(systemName: "pause.fill"), for: UIControl.State.normal)
        case .paused, .stopped:
            playButton.setImage(UIImage(systemName: "play.fill"), for: UIControl.State.normal)
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
    
    func scrollToNowPlayingItem(animated: Bool = true) {
        guard ConnectionController.shared.isDJ != nil else { return }
        
        let numberOfRequestedSongs = ConnectionController.shared.isDJ
                                   ? PlayerQueue.shared.count()
                                   : ConnectionController.shared.receivedSongs.count
        guard numberOfRequestedSongs != 0 else { return }
        
        let indexOfNowPlayingItem  = ConnectionController.shared.isDJ
                                   ? PlayerQueue.shared.mpAppController.indexOfNowPlayingItem
                                   : RequestsViewController.self.indexOfNowPlayingItemOnListener
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: indexOfNowPlayingItem, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: animated)
        }
    }
    
    func animateShrinkDown(view: UIView, scale: CGFloat) {
        UIView.animate(withDuration: 0.05, delay: 0.0, animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale);
        }, completion: { _ in
            view.transform = CGAffineTransform(scaleX: scale, y: scale);
        })
    }
    
    func animateGrowUp(view: UIView) {
        UIView.animate(withDuration: 0.05, delay: 0.0, animations: {
            view.transform = CGAffineTransform.identity;
        }, completion: { _ in
            view.transform = CGAffineTransform.identity;
        })
    }
    
    @IBAction func playButtonTouchDown(_ sender: Any) {
        // アニメーション
        animateShrinkDown(view: self.playButtonBackgroundView, scale: 0.9)
    }
    
    @IBAction func playButtonTouchUp(_ sender: Any) {
        // アニメーション
        animateGrowUp(view: self.playButtonBackgroundView)
        
        // 曲の再生・停止
        switch PlayerQueue.shared.mpAppController.playbackState {
        case .playing:          // 再生中なら停止する
            PlayerQueue.shared.mpAppController.pause()
        case .paused, .stopped: // 停止中なら再生する
            PlayerQueue.shared.mpAppController.play()
        default:
            break
        }
    }
    
    @IBAction func skipButtonTouchDown(_ sender: Any) {
        // アニメーション
        animateShrinkDown(view: self.skipButton, scale: 0.75)
    }
    
    @IBAction func skipButtonTouchUp(_ sender: Any) {
        // アニメーション
        animateGrowUp(view: self.skipButton)
        
        // 曲のスキップ
        PlayerQueue.shared.mpAppController.skipToNextItem()
    }
    
    @IBAction func batterySaverButtonTouchDown(_ sender: Any) {
        // アニメーション
        animateShrinkDown(view: self.batterySaverButton, scale: 0.75)
    }
    
    @IBAction func batterySaverButtonTouchUp(_ sender: Any) {
        // アニメーション
        animateGrowUp(view: self.batterySaverButton)
    }
    
    @IBAction func reloadButton(_ sender: Any) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        scrollToNowPlayingItem()
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
        if let profileImageUrl = song.profileImageUrl {
            cell.profileImageView.image = Artwork.fetch(url: profileImageUrl)
        }
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

// MARK: - UITableViewDelegate

extension RequestsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)  // セルの選択を解除
        if ConnectionController.shared.isDJ {   // 自分がDJのとき
            // 曲を再生する
            PlayerQueue.shared.play(at: indexPath.row)
        }
    }
    
}
