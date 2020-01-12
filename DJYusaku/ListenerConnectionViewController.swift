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
        let djPeerID = ConnectionController.shared.connectableDJs[indexPath.row]
        if let profile = ConnectionController.shared.peerProfileCorrespondence[djPeerID] {
            cell.djName?.text = profile.name

            DispatchQueue.global().async {
                if let imageUrl = profile.imageUrl {
                    DJImage = CachedImage.fetch(url: imageUrl)
                }
                DispatchQueue.main.async {
                    cell.djImageView.image = DJImage ?? UIImage(named: "TemporarySingleColored")
                }
            }
        } else {
            cell.djName?.text = djPeerID.displayName

            cell.djImageView.image = UIImage(named: "TemporarySingleColored")
        }
        
        if let numberOfParticipants = ConnectionController.shared.numberOfParticipantsCorrespondence[djPeerID] {
            cell.numberOfParticipantsLabel?.text = "\(numberOfParticipants)/8"
            if numberOfParticipants >= 8 {
                cell.numberOfParticipantsLabel?.layer.backgroundColor = UIColor.red.cgColor
                cell.djImageView.alpha = 0.3
                cell.djName.alpha      = 0.3
                cell.selectionStyle    = .none
            } else {
                cell.numberOfParticipantsLabel?.layer.backgroundColor = UIColor.separator.cgColor
                cell.djImageView.alpha = 1
                cell.djName.alpha      = 1
                cell.selectionStyle    = .default
            }
        } else {
            cell.numberOfParticipantsLabel?.text = "?/8"
            cell.numberOfParticipantsLabel?.layer.backgroundColor = UIColor.separator.cgColor
            cell.djImageView.alpha = 1
            cell.djName.alpha      = 1
            cell.selectionStyle    = .default
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListenerConnectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let numberOfParticipants = ConnectionController.shared.numberOfParticipantsCorrespondence[ConnectionController.shared.connectableDJs[indexPath.row]] else { return }
        if numberOfParticipants < 8 {
            let selectedDJ = ConnectionController.shared.connectableDJs[indexPath.row]
            if let connectedDJ = ConnectionController.shared.connectedDJ, connectedDJ.state == .connecting {
                let alertController = UIAlertController(title:   "You are now trying to connect".localized,
                                                        message: "Please wait up to process is completed.".localized,
                                                        preferredStyle: UIAlertController.Style.alert)
                let alertButton = UIAlertAction(title: "OK",
                                                style: UIAlertAction.Style.cancel)
                alertController.addAction(alertButton)
                self.present(alertController, animated: true, completion: nil)
            } else {
                ConnectionController.shared.startListener(selectedDJ: selectedDJ)
                self.dismiss(animated: true)
            }
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
