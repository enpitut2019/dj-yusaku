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
        MusicDataModel(title: "Happier", artist: "Marshmello", artworkUrl: Artwork.url(urlString: "https://img.discogs.com/osP7UHCvBmZDrdIlpDgW6ifpaXU=/fit-in/600x595/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-13426814-1553984554-3921.png.jpg", width: 256, height: 256)),
        MusicDataModel(title: "Billie Jean", artist: "Michael Jackson", artworkUrl: Artwork.url(urlString: "https://images-na.ssl-images-amazon.com/images/I/51Mz7YQ0e0L._AC_.jpg", width: 256, height: 256)),
        MusicDataModel(title: "Pretender", artist: "Official髭男dism", artworkUrl: Artwork.url(urlString: "https://cdn.utaten.com/uploads/images/specialArticle/3909/thumbnail/0x800/591283d7ae5bae31c486e1babe0db1af6fffcfcf.jpeg", width: 256, height: 256)),
        MusicDataModel(title: "MIND CONDUCTOR", artist: "YURiKA", artworkUrl: Artwork.url(urlString: "https://images-na.ssl-images-amazon.com/images/I/81aMFhI4G6L._AC_SL1500_.jpg", width: 256, height: 256)),
        MusicDataModel(title: "留学生", artist: "MONKEY MAJIK × 岡崎体育", artworkUrl: Artwork.url(urlString: "https://images-na.ssl-images-amazon.com/images/I/61J8sAYJNuL._AC_SL1000_.jpg", width: 256, height: 256)),
        MusicDataModel(title: "負け犬にアンコールはいらない", artist: "ヨルシカ", artworkUrl: Artwork.url(urlString: "https://images-na.ssl-images-amazon.com/images/I/81yDGHPwMfL._AC_SL1419_.jpg", width: 256, height: 256)),
        MusicDataModel(title: "KISS OFLIFE", artist: "平井堅", artworkUrl: Artwork.url(urlString: "https://images-na.ssl-images-amazon.com/images/I/71XT%2BN5llOL._AC_SL1221_.jpg", width: 256, height: 256)),
        MusicDataModel(title: "papa", artist: "Orange range", artworkUrl: Artwork.url(urlString: "https://images-na.ssl-images-amazon.com/images/I/61MIuaFTX0L._AC_.jpg", width: 256, height: 256)),
        MusicDataModel(title: "Solar System", artist: "Sub Focus", artworkUrl: Artwork.url(urlString: "https://img.discogs.com/ZDQTTaoZDcoYhdnr1kvB9-3ow0k=/fit-in/600x600/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-13923579-1564159903-8551.jpeg.jpg", width: 256, height: 256)),
        MusicDataModel(title: "ミツバチ", artist: "遊助", artworkUrl: Artwork.url(urlString: "https://images-na.ssl-images-amazon.com/images/I/51tx6bZYM8L._AC_.jpg", width: 256, height: 256)),
        MusicDataModel(title: "September", artist: "Earth Wind & Fire", artworkUrl: Artwork.url(urlString: "https://cdn.utaten.com/uploads/images/specialArticle/446/thumbnail/0x800/image.jpeg", width: 256, height: 256)),
        MusicDataModel(title: "Mr.Suicide", artist: "9mm Parabellum Bullet", artworkUrl: Artwork.url(urlString: "https://images-na.ssl-images-amazon.com/images/I/51CNfp1bYiL._AC_.jpg", width: 256, height: 256))
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
                let alertButton = UIAlertAction(title: "OK",
                                                 style: UIAlertAction.Style.cancel, handler: nil)
                alertController.addAction(alertButton)
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
            requests.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
