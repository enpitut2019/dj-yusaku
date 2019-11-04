//
//  ListenerConnecterViewController.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/02.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ListenerConnecterViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (!MCConnecter.shared.initialized) {
            MCConnecter.shared.initialize(isParent: false, displayName: UIDevice.current.name)
        }
        MCConnecter.shared.delegate = self
        MCConnecter.shared.startBrowse()
        
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

extension ListenerConnecterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MCConnecter.shared.connectableDJs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectableDJsTableViewCell", for: indexPath) as! ConnectableDJsTableViewCell
        let item = MCConnecter.shared.connectableDJs[indexPath.row]
        cell.djName?.text = "DJ: " + item.displayName
        print("DJ: [" + item.displayName + "]")

        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MCConnecter.shared.browser.invitePeer(MCConnecter.shared.connectableDJs[indexPath.row], to: MCConnecter.shared.session, withContext: nil, timeout: 10.0)
        MCConnecter.shared.stopBrowse()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension ListenerConnecterViewController: UITableViewDelegate {
    /* TODO: 未実装 */
}

// MARK: - MCConnecterDelegate
extension ListenerConnecterViewController: MCConnecterDelegate {
    func mcConnecter(didReceiveData data: Data, from peerID: MCPeerID) {
        
    }

    func mcConnecter(connectableDevicesChanged devices: [MCPeerID]) {
        print("changed")
        self.tableView.reloadData()
    }
}
