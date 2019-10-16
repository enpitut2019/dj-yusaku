//
//  SearchViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/12.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import StoreKit

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private let cloudServiceController = SKCloudServiceController()
    private var storefrontCountryCode : String? = nil
    
    // 表示確認用サンプルデータ
    let results = [
        MusicDataModel(title: "Come Together", artist: "The Beatles"),
        MusicDataModel(title: "Something", artist: "The Beatles"),
        MusicDataModel(title: "Oh! Darling", artist: "The Beatles")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 空のセルの罫線を消す
        
        // Apple Musicライブラリへのアクセス許可の確認
        SKCloudServiceController.requestAuthorization { status in
            guard status == .authorized else { return }
            // TODO: Apple Musicの契約確認処理
        }
        // Apple Musicのロケール設定
        self.cloudServiceController.requestStorefrontCountryCode { (storefrontCountryCode, error) in
            if error != nil { return } // TODO: エラー処理これでいいのか？
            self.storefrontCountryCode = storefrontCountryCode
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMusicTableViewCell", for: indexPath) as! SearchMusicTableViewCell
        
        let item = results[indexPath.row]
        cell.title.text = item.title
        cell.artist.text = item.artist

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    /* TODO: 未実装 */
}
    
// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        // 検索文字列の取得
        let searchString = searchController.searchBar.text ?? ""
        if searchString.isEmpty { return }  // 空なら検索しない
        
        // 検索用URLの作成
        var url : URL
        if let storeFront = self.storefrontCountryCode {
            var urlComponents = URLComponents(string: "https://api.music.apple.com/v1/catalog/\(storeFront)/search")!
            urlComponents.queryItems = [
                URLQueryItem(name: "term", value: searchString),    // 検索キーワード
                URLQueryItem(name: "limit", value: "25"),           // 取得件数 (最大25件)
                URLQueryItem(name: "types", value: "songs"),        // 検索種別 (複数可能)
            ]
            url = urlComponents.url!
        } else { return } // ストアフロント取得に失敗していたら何もしない
        
        // GETリクエスト作成
        var request = URLRequest(url: url)
        request.addValue("Bearer \(Secrets.DeveloperToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil, let data = data else { return }
            // JSONの処理
        }
        
        // 検索の実行
        task.resume()
    }
}

// MARK: - UIBarPositioningDelegate

extension SearchViewController: UIBarPositioningDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached;
    }

}
