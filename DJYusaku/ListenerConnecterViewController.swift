//
//  ListenerConnecterViewController.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/11/02.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class ListenerConnecterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (MCConnecter.shared.session != nil) { }
        else {
        MCConnecter.shared.initialize(isParent: false, displayName: UIDevice.current.name)
        }
        
        MCConnecter.shared.startBrowse()
        // tableViewのdelegate, dataSource設定
        tableView.delegate = self
        tableView.dataSource = self
        
        print("connectableDJs: ",MCConnecter.shared.connectableDJs)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectableDJsTableViewCell", for: indexPath) as! SearchMusicTableViewCell
        
        let item = MCConnecter.shared.connectableDJs[indexPath.row]
        cell.title.text       = item.displayName
        cell.button.isEnabled = true
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListenerConnecterViewController: UITableViewDelegate {
    /* TODO: 未実装 */
}
