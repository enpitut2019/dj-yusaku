//
//  SearchMusicTableViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/12.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import StoreKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let results = [
        MusicDataModel(title: "Maybe I'm Amazed", artist: "Paul McCartney"),
        MusicDataModel(title: "Sir Duke", artist: "Stevie Wonder"),
        MusicDataModel(title: "Rock With You", artist: "Michael Jackson")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        SKCloudServiceController.requestAuthorization { status in
            guard status == .authorized else { return }
            // できたとき
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicTableViewCell", for: indexPath) as! MusicTableViewCell
        
        let item = results[indexPath.row]
        cell.title.text = item.title
        cell.artist.text = item.artist

        return cell
    }
    
    // MARK: - UITableViewDelegate

}
