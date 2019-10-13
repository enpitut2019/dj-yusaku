//
//  FirstViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/05.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // 表示確認用サンプルデータ
    let results = [
        MusicDataModel(title: "Come Together", artist: "The Beatles"),
        MusicDataModel(title: "Something", artist: "The Beatles"),
        MusicDataModel(title: "Maxwell's Silver Hammer", artist: "The Beatles"),
        MusicDataModel(title: "Oh! Darling", artist: "The Beatles"),
        MusicDataModel(title: "Octopus's Garden", artist: "The Beatles"),
        MusicDataModel(title: "I Want You (She's So Heavy)", artist: "The Beatles"),
        MusicDataModel(title: "Here Comes The Sun", artist: "The Beatles"),
        MusicDataModel(title: "Because", artist: "The Beatles"),
        MusicDataModel(title: "You Never Give Me Your Money", artist: "The Beatles"),
        MusicDataModel(title: "Sun King", artist: "The Beatles"),
        MusicDataModel(title: "Mean Mr. Mustard", artist: "The Beatles"),
        MusicDataModel(title: "Polythene Pam", artist: "The Beatles"),
        MusicDataModel(title: "She Came In Through The Bathroom Window", artist: "The Beatles"),
        MusicDataModel(title: "Golden Slumbers", artist: "The Beatles"),
        MusicDataModel(title: "Carry That Weight", artist: "The Beatles"),
        MusicDataModel(title: "The End", artist: "The Beatles"),
        MusicDataModel(title: "Her Majesty", artist: "The Beatles")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 空のセルの罫線を消す
    }
}

// MARK: - UITableViewDataSource

extension RequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicTableViewCell", for: indexPath) as! MusicTableViewCell
        
        let item = results[indexPath.row]
        cell.title.text = item.title
        cell.artist.text = item.artist

        return cell
    }
}

// MARK: - UITableViewDelegate

extension RequestsViewController: UITableViewDelegate {
    /* TODO: 未実装 */
}
