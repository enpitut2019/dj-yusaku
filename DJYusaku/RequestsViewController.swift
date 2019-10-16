//
//  RequestsViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/05.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playingArtwork: UIImageView!
    @IBOutlet weak var playingTitle: UILabel!
    
    // 表示確認用サンプルデータ
    var requests = [
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
