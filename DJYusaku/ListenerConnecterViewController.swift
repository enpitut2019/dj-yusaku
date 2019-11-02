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

        if (MCConnecter.shared.session != nil) {
            print("aaaa")
        }
        else {
            MCConnecter.shared.initialize(isParent: false, displayName: UIDevice.current.name)
            MCConnecter.shared.startBrowse()
            print("bbbbb")
        }
        
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
        
        print("connectableDJs: ",MCConnecter.shared.connectableDJs)
        
        // NotificationCenter.default.addObserver(self, selector: #selector(handleDJUpdated), name: .welcomeVCToListenerConnecterVCName, object: nil)
    }
    
//    @objc func handleDJUpdated () {
//        // リクエスト画面を更新
//        DispatchQueue.main.async{
//            self.tableView.reloadData()
//        }
//        print("update")
//    }

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
        print("vcccccc")
        return MCConnecter.shared.connectableDJs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectableDJsTableViewCell", for: indexPath) as! ConnectableDJsTableViewCell
        let item = MCConnecter.shared.connectableDJs[indexPath.row]
        cell.djName?.text = "DJ: " + item.displayName
        print("DJ: " + item.displayName)
        
        // リクエスト画面を更新
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListenerConnecterViewController: UITableViewDelegate {
    /* TODO: 未実装 */
}

// MARK: - MCConnecterDelegate
extension ListenerConnecterViewController: MCConnecterDelegate {
    func mcConnecter(didReceiveData data: Data, ofType type: UInt32) {
        
    }
    
    func mcConnecter(connectedDevicesChanged devices: [String]) {
        
    }
    

    func mcConnecter(connectableDevicesChanged devices: [MCPeerID], browser: MCNearbyServiceBrowser) {
        print(devices)
        self.tableView.reloadData()
    }
}
