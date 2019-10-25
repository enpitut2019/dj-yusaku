//
//  RequestsViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/05.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import StoreKit

class RequestsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playingArtwork: UIImageView!
    @IBOutlet weak var playingTitle: UILabel!
    

//    var requests = RequestQueue.shared
    // 表示確認用サンプルデータ
    private var requests = [
        MusicDataModel(title: "Happier", artist: "Marshmello", artworkUrl: Artwork.url(urlString: "https://music.apple.com/jp/album/happier/1424703172?i=1424704480", width: 256, height: 256))
    ]
    private let cloudServiceController = SKCloudServiceController()
    private let defaultArtwork : UIImage = UIImage()
    private var storefrontCountryCode : String? = nil
    
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
        // Apple Musicのロケール設定
        self.cloudServiceController.requestStorefrontCountryCode { (storefrontCountryCode, error) in
            if error != nil {
                // アラートを表示
                let alertController = UIAlertController(title: "Apple Musicの情報の取得に失敗しました",
                                                        message: "iCloudのログインを確認してください",
                                                        preferredStyle: UIAlertController.Style.alert)
                let allertButton = UIAlertAction(title: "OK",
                                                 style: UIAlertAction.Style.cancel, handler: nil)
                alertController.addAction(allertButton)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.storefrontCountryCode = storefrontCountryCode
        }
        
        
        let footerView = UIView()
        footerView.frame.size.height = tableView.rowHeight
        tableView.tableFooterView = footerView // 空のセルの罫線を消す
        
        playingArtwork.layer.cornerRadius = playingArtwork.frame.size.width * 0.05
        playingArtwork.clipsToBounds = true
    }
}


// MARK: - UITableViewDataSource

extension RequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsMusicTableViewCell", for: indexPath) as! RequestsMusicTableViewCell
        
        let item = requests[indexPath.row]
        cell.title.text = item.title
        cell.artist.text = item.artist
        cell.artwork.image = defaultArtwork
        
        let fetchedImage = Artwork.fetch(url: item.artworkUrl)
        cell.artwork.image = fetchedImage // 画像の取得に失敗していたらnilが入ることに注意
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RequestsViewController: UITableViewDelegate {
    // セルの編集時の挙動
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            requests.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
