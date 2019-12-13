//
//  MemberViewController.swift
//  DJYusaku
//
//  Created by Yuu Ichikawa on 2019/11/23.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MemberViewController: UIViewController {
    
    private var childPeers : [MCPeerID] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var parentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewのdataSource設定
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePeerConnectionStateDidUpdate), name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
        
        childPeers = ConnectionController.shared.session.connectedPeers.filter({ $0 != ConnectionController.shared.connectedDJ })
        
        if !ConnectionController.shared.isParent {
            self.childPeers.insert(ConnectionController.shared.peerID, at: 0) //自分の端末を子機群の先頭に挿入
        }
       
        DispatchQueue.main.async{
            if ConnectionController.shared.isParent {  //親機ならば、自分の端末名を表示する
                self.parentNameLabel.text = ConnectionController.shared.peerID.displayName
            }else{                                      //子機ならば、
                self.parentNameLabel.text = ConnectionController.shared.connectedDJ.displayName //接続している端末名＝親機を表示する
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, animations: { [unowned self] in
            self.parentImageView.frame.size.width  -= 20
            self.parentImageView.frame.size.height -= 20
            self.parentImageView.center.x += 10
            self.parentImageView.center.y += 10
        })
    }
    
    @objc func handlePeerConnectionStateDidUpdate() {
        // 接続している端末＝親機はtableViewには表示しないので除去
        childPeers = ConnectionController.shared.session.connectedPeers.filter({ $0 != ConnectionController.shared.connectedDJ })
        
        if !ConnectionController.shared.isParent {
            self.childPeers.insert(ConnectionController.shared.peerID, at: 0) //自分の端末を子機群の先頭に挿入
        }
        //親が変わったときに親機表示部分のLabelを更新
        DispatchQueue.main.async{
            if (ConnectionController.shared.isParent){  //親機ならば、自分の端末名を表示する
                self.parentNameLabel.text = ConnectionController.shared.peerID.displayName
            }else{                                      //子機ならば、接続している端末名＝親機を表示する
                self.parentNameLabel.text = ConnectionController.shared.connectedDJ.displayName
            }
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - UITableViewDataSource

extension MemberViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        cell.peerName.text = childPeers[indexPath.row].displayName
        return cell
    }
 }

