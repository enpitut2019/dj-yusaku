//
//  ListenerConnectionViewController.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/06.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ListenerConnectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        ConnectionController.shared.startBrowse()
        ConnectionController.shared.delegate = self
        
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ConnectionController.shared.stopBrowse()
        ConnectionController.shared.connectableDJs.removeAll()
    }

}

// MARK: - UITableViewDataSource

extension ListenerConnectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConnectionController.shared.connectableDJs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListenerConnectableDJsTableViewCell", for: indexPath) as! ListenerConnectableDJsTableViewCell
        let peerID = ConnectionController.shared.connectableDJs[indexPath.row]
        if let profile = ConnectionController.shared.peerProfileCorrespondence[peerID] {
            cell.djName?.text = profile.name
            if let imageUrl = profile.imageUrl {
                cell.djImageView.image = CachedImage.fetch(url: imageUrl)
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListenerConnectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDJ = ConnectionController.shared.connectableDJs[indexPath.row]
        self.dismiss(animated: true) {
            ConnectionController.shared.startListener(selectedDJ: selectedDJ)
        }
    }
}

// MARK: - ConnectionControllerDelegate

extension ListenerConnectionViewController: ConnectionControllerDelegate {
    func connectionController(didChangeConnectableDevices devices: [MCPeerID]) {
        // browserがピアを見つけたらリロード
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
