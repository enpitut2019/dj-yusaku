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
    
    private let cloudServiceController = SKCloudServiceController()
    private let defaultArtwork : UIImage = UIImage()
    private var storefrontCountryCode : String? = nil
    
    private let musicPlayer : MPMusicPlayerController! = MPMusicPlayerController.systemMusicPlayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
        
        // Apple Musicライブラリへのアクセス許可の確認
        SKCloudServiceController.requestAuthorization { status in
            guard status == .authorized else { return }
            // TODO: Apple Musicの契約確認処理
        }
        // Apple Musicの曲が再生可能か確認（Apple Musicの契約確認処理と同義？）
        self.cloudServiceController.requestCapabilities { (capabilities, error) in
            guard capabilities.contains(.musicCatalogPlayback) else { return }
        }
        
        
        let footerView = UIView()
        footerView.frame.size.height = tableView.rowHeight
        tableView.tableFooterView = footerView // 空のセルの罫線を消す
        
        playingArtwork.layer.cornerRadius = playingArtwork.frame.size.width * 0.05
        playingArtwork.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRequests), name: .requestQueueToRequestsVCName, object: nil)
    }
    
    @objc func updateRequests(){
        tableView.reloadData()
    }
    
    
    func updateMusicPlayerControllerQueue(){
        
    }
}

// MARK: - UITableViewDataSource

extension RequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RequestQueue.shared.countRequests()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsMusicTableViewCell", for: indexPath) as! RequestsMusicTableViewCell
        
        let item = RequestQueue.shared.getRequest(indexPath: indexPath.row)
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
            RequestQueue.shared.deleteRequest(indexPath: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
