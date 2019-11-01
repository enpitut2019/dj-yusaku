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
    @IBOutlet weak var skipButton: UIButton!
    private var isViewAppearedAtLeastOnce: Bool = false;
    
    private let cloudServiceController = SKCloudServiceController()
    private let defaultArtwork : UIImage = UIImage()
    private var storefrontCountryCode : String? = nil
    
    private let musicPlayerApplicationController = MPMusicPlayerController.applicationQueuePlayer
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequestsUpdated), name: .requestQueueToRequestsVCName, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(handlePlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
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
    
    @objc func handlePlayingItemChanged(notification: NSNotification){
        guard RequestQueue.shared.countRequests() > 0 else { return }
        let nowPlayingMusicDataModel = RequestQueue.shared.getRequest(index: 0)
        RequestQueue.shared.removeRequest(index: 0)
        DispatchQueue.global().async {
            let fetchedImage = Artwork.fetch(url: nowPlayingMusicDataModel.artworkUrl)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.playingTitle.text    = nowPlayingMusicDataModel.title
                self.playingArtwork.image = fetchedImage

            }
        }
    }
    
    @objc func handleRequestsUpdated(notification: NSNotification){
        print("handleRequestsUpdated")
        // リクエスト画面を更新
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
        guard let songID = notification.userInfo!["songID"] as? String,
              let title  = notification.userInfo!["title"]  as? String else { return }
        
        // リクエストが完了した旨のAlertを表示
        let alert = UIAlertController(title: title, message: "was requested", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        
        insertMusicPlayerControllerQueue(songID: songID)
    }
    
    func insertMusicPlayerControllerQueue(songID : String){
        
        if (self.musicPlayerApplicationController.nowPlayingItem != nil){ // FIXME: 一度キューを空にしたつもりでもnowPlayingItemはnilにならない
            musicPlayerApplicationController.perform(queueTransaction: { mutableQueue in
                let descripter = MPMusicPlayerStoreQueueDescriptor(storeIDs: [songID])

                mutableQueue.insert(descripter, after: mutableQueue.items.last)
            }, completionHandler: { queue, error in
                if (error != nil){
                    // TODO: キューへの追加ができなかった時の処理を記述
                }
            })
        } else {
            let descripter = MPMusicPlayerStoreQueueDescriptor(storeIDs: [songID])
            musicPlayerApplicationController.setQueue(with: descripter)
            musicPlayerApplicationController.play()

        }
    }
    
    @IBAction func skip(_ sender: Any) {
        // TODO: 暫定的な処理だしバグもあるからRequesrQueueの再設計後に直す
        guard RequestQueue.shared.countRequests() != 0 else { return }
        musicPlayerApplicationController.perform(queueTransaction: { [unowned self] mutableQueue in
            guard self.musicPlayerApplicationController.nowPlayingItem != nil else { return }
            // キューの先頭を削除する
            self.musicPlayerApplicationController.skipToNextItem()
            mutableQueue.remove(mutableQueue.items[0])
        }, completionHandler: { [unowned self] queue, error in
            guard self.musicPlayerApplicationController.nowPlayingItem != nil && error == nil else { return }
            // 何もしない
        })
    }
    
}


// MARK: - UITableViewDataSource

extension RequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RequestQueue.shared.countRequests()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsMusicTableViewCell", for: indexPath) as! RequestsMusicTableViewCell
        
        let item = RequestQueue.shared.getRequest(index: indexPath.row)
        cell.title.text = item.title
        cell.artist.text = item.artist
        cell.artwork.image = defaultArtwork
        
        DispatchQueue.global().async {
            let fetchedImage = Artwork.fetch(url: item.artworkUrl)
            DispatchQueue.main.async {
                cell.artwork.image = fetchedImage // 画像の取得に失敗していたらnilが入ることに注意
                cell.artwork.setNeedsLayout()
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RequestsViewController: UITableViewDelegate {
    // セルの編集時の挙動
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            RequestQueue.shared.removeRequest(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            //TODO: playerのqueueの中も削除
        }
    }
}
