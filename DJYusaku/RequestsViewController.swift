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

class RequestsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playingArtwork: UIImageView!
    @IBOutlet weak var playingTitle: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    private var isViewAppearedAtLeastOnce: Bool = false;
    
    private let cloudServiceController = SKCloudServiceController()
    private let defaultArtwork : UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
        
        let footerView = UIView()
        footerView.frame.size.height = tableView.rowHeight
        tableView.tableFooterView = footerView // 空のセルの罫線を消す
        
        playingArtwork.layer.cornerRadius = playingArtwork.frame.size.width * 0.05
        playingArtwork.clipsToBounds = true
        
        // Apple Musicライブラリへのアクセス許可の確認
        SKCloudServiceController.requestAuthorization { status in
            guard status == .authorized else { return }
            // Apple Musicの曲が再生可能か確認
            self.cloudServiceController.requestCapabilities { (capabilities, error) in
                guard error == nil && capabilities.contains(.musicCatalogPlayback) else { return }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequestsDidUpdate), name:
            .DJYusakuPlayerQueueDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNowPlayingItemDidChange), name: .DJYusakuPlayerQueueNowPlayingSongDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackStateDidChange), name: .DJYusakuPlayerQueuePlaybackStateDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isViewAppearedAtLeastOnce {  // 初回だけ表示する画面遷移に使う
            // 初回にはWelcomeViewをモーダルを表示
            let storyboard: UIStoryboard = self.storyboard!
            let welcomNavigationController = storyboard.instantiateViewController(withIdentifier: "WelcomeNavigation")
            welcomNavigationController.isModalInPresentation = true
            self.present(welcomNavigationController, animated: true)
            
            // 2度目以降の表示はしない
            self.isViewAppearedAtLeastOnce = true
        }
    }
    
    @objc func handleRequestsDidUpdate(notification: NSNotification){
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    @objc func handleNowPlayingItemDidChange(notification: NSNotification){
        guard let nowPlayingItem = PlayerQueue.shared.mpAppController.nowPlayingItem else { return }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.playingTitle.text    = nowPlayingItem.title
            self.playingArtwork.image = nowPlayingItem.artwork?.image(at: CGSize(width: 48, height: 48))
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
}

// MARK: - UITableViewDataSource

extension RequestsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlayerQueue.shared.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsMusicTableViewCell", for: indexPath) as! RequestsMusicTableViewCell
        guard let item = PlayerQueue.shared.get(at: indexPath.row) else { return cell }
        
        cell.title.text    = item.title
        cell.artist.text   = item.artist
        cell.artwork.image = item.artwork?.image(at: CGSize(width: 48,height: 48))
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RequestsViewController: UITableViewDelegate {
    // セルの編集時の挙動
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            PlayerQueue.shared.remove(at: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .left)  // 必ずPlayerQueueの処理後にTableViewの更新を行う
            }
        }
    }
}
