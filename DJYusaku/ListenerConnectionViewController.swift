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
        var DJImage: UIImage?
        let profile = ConnectionController.shared.peerProfileCorrespondence[ConnectionController.shared.connectableDJs[indexPath.row]]!
        cell.djName?.text = profile.name
        if let numberOfParticipants = ConnectionController.shared.NumberOfParticipantsCorrespondence[ConnectionController.shared.connectableDJs[indexPath.row]] {
            cell.numberOfParticipants?.text = "\(numberOfParticipants)/8"
            if numberOfParticipants == 8 {
                cell.numberOfParticipantsBackgroundView.layer.backgroundColor = CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            }
        }
        DispatchQueue.global().async {
            if let imageUrl = profile.imageUrl {
                DJImage = CachedImage.fetch(url: imageUrl)
            }
            DispatchQueue.main.async {
                cell.djImageView.image = DJImage ?? UIImage(named: "TemporarySingleColored")
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListenerConnectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDJ = ConnectionController.shared.connectableDJs[indexPath.row]
        ConnectionController.shared.startListener(selectedDJ: selectedDJ)
        self.dismiss(animated: true)
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
