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
    
    private var listeners : [MCPeerID] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var djNameLabel: UILabel!
    @IBOutlet weak var djImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewのdataSource設定
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePeerConnectionStateDidUpdate), name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
        
        setupListeners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, animations: { [unowned self] in
            self.djImageView.frame.size.width  -= 20
            self.djImageView.frame.size.height -= 20
            self.djImageView.center.x += 10
            self.djImageView.center.y += 10
        })
    }
    
    func setupListeners() {
        var DJIcon:UIImage?
        // 接続している端末＝親機はtableViewには表示しないので除去
          listeners = ConnectionController.shared.session.connectedPeers.filter({ $0 != ConnectionController.shared.connectedDJ })
          
          if !ConnectionController.shared.isDJ {
              self.listeners.insert(ConnectionController.shared.peerID, at: 0) //自分の端末を子機群の先頭に挿入
          }
        if ConnectionController.shared.isDJ {
            if let iconURL = ConnectionController.shared.iconURL {
                DJIcon = Artwork.fetch(url: iconURL)
            }
        } else {
            if let iconURL = ConnectionController.shared.iconURLCorrespondence[ ConnectionController.shared.connectedDJ] {
                DJIcon = Artwork.fetch(url: iconURL)
            }
        }
        //親が変わったときに親機表示部分のLabelを更新
        DispatchQueue.main.async{
            if ConnectionController.shared.isDJ {  //親機ならば、自分の端末名を表示する
                self.djNameLabel.text = ConnectionController.shared.peerID.displayName
                if DJIcon != nil {
                    self.djImageView.image = DJIcon
                }
            } else {
                //子機ならば、接続している端末名＝親機を表示する
                self.djNameLabel.text = ConnectionController.shared.connectedDJ.displayName
                if DJIcon != nil {
                    self.djImageView.image = DJIcon
                }
            }
            self.tableView.reloadData()
        }
    }
    
    @objc func handlePeerConnectionStateDidUpdate() {
        setupListeners()
    }
    
}

// MARK: - UITableViewDataSource

extension MemberViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listeners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        cell.peerName.text = listeners[indexPath.row].displayName
        
        DispatchQueue.global().async {
            var listenerIcon: UIImage?
            if let iconURL = ConnectionController.shared.iconURLCorrespondence[self.listeners[indexPath.row]] {
                listenerIcon = Artwork.fetch(url: iconURL)
            }
            DispatchQueue.main.async {
                if listenerIcon != nil {
                    cell.peerImage.image = listenerIcon
                }
                cell.peerImage.setNeedsLayout()
            }
        }
        return cell
    }
 }

