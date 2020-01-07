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
    @IBOutlet weak var noConnectableDJsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ConnectionController.shared.startBrowse()
        ConnectionController.shared.delegate = self
        
        noConnectableDJsView.isHidden = false
        
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 空のセルの罫線を消す
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: .DJYusakuModalViewDidDisappear, object: nil)
        
        ConnectionController.shared.stopBrowse()
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
        if let numberOfParticipants = ConnectionController.shared.numberOfParticipantsCorrespondence[ConnectionController.shared.connectableDJs[indexPath.row]] {
            cell.numberOfParticipantsLabel?.text = "\(numberOfParticipants)/8"
            if numberOfParticipants == 8 {
                cell.numberOfParticipantsLabel?.layer.backgroundColor = UIColor.red.cgColor
                cell.djImageView.alpha = 0.3
                cell.djName.alpha      = 0.3
                cell.selectionStyle    = .none
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
        if ConnectionController.shared.numberOfParticipantsCorrespondence[ConnectionController.shared.connectableDJs[indexPath.row]] != 8 {
            let selectedDJ = ConnectionController.shared.connectableDJs[indexPath.row]
            ConnectionController.shared.startListener(selectedDJ: selectedDJ)
            self.dismiss(animated: true)
        }
    }
}

// MARK: - ConnectionControllerDelegate

extension ListenerConnectionViewController: ConnectionControllerDelegate {
    func connectionController(didChangeConnectableDevices devices: [MCPeerID]) {
        // browserによって接続可能なピアが変化したらリロード
        DispatchQueue.main.async {
                self.noConnectableDJsView.isHidden = !ConnectionController.shared.connectableDJs.isEmpty
            self.tableView.reloadData()
        }
    }
}
