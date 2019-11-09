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

        ConnectionController.shared.initialize(isParent: false, displayName: UIDevice.current.name)
        ConnectionController.shared.delegate = self
        ConnectionController.shared.startBrowse()
        
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITableViewDataSource

extension ListenerConnectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConnectionController.shared.connectableDJs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListenerConnectableDJsTableViewCell", for: indexPath) as! ListenerConnectableDJsTableViewCell
        let item = ConnectionController.shared.connectableDJs[indexPath.row]
        cell.djName?.text = "DJ: " + item.displayName

        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDJ = ConnectionController.shared.connectableDJs[indexPath.row]
        ConnectionController.shared.browser.invitePeer(selectedDJ, to: ConnectionController.shared.session, withContext: nil, timeout: 10.0)
        ConnectionController.shared.connectedDJ = selectedDJ
        ConnectionController.shared.stopBrowse()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension ListenerConnectionViewController: UITableViewDelegate {
    /* TODO: 未実装 */
}

// MARK: - ConnectionControllerDelegate

extension ListenerConnectionViewController: ConnectionControllerDelegate {
    func connectionController(didReceiveData data: Data, from peerID: MCPeerID) {
        
    }

    func connectionController(didChangeConnectableDevices devices: [MCPeerID]) {
        // browserがピアを見つけたらリロード
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
