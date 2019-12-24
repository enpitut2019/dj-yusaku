//
//  MemberViewController.swift
//  DJYusaku
//
//  Created by Yuu Ichikawa on 2019/11/23.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import Swifter
import MultipeerConnectivity

class MemberViewController: UIViewController {
    
    private var listeners : [MCPeerID] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var DJNameLabel: UILabel!
    @IBOutlet weak var DJImageView: UIImageView!
    @IBOutlet weak var DJStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewのdataSource設定
        tableView.dataSource = self
        
        // DJのアイコン画像を円形にする
        DJImageView.layer.cornerRadius = DJImageView.frame.size.height * 0.5
        DJImageView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePeerConnectionStateDidUpdate), name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateMembers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, animations: { [unowned self] in
            self.DJImageView.frame.size.width  -= 20
            self.DJImageView.frame.size.height -= 20
            self.DJImageView.center.x += 10
            self.DJImageView.center.y += 10
        })
    }
    
    func updateMembers() {
        var DJName = ConnectionController.shared.isDJ!
                   ? ConnectionController.shared.peerID.displayName
                   : ConnectionController.shared.connectedDJ!.peerID.displayName
        var DJIcon: UIImage? = UIImage(named: "TemporarySingleColored")
        
        listeners = ConnectionController.shared.session.connectedPeers
        
        if !ConnectionController.shared.isDJ! {
            // 接続している端末（親機）はtableViewには表示しない
            self.listeners = self.listeners.filter({ $0 != ConnectionController.shared.connectedDJ!.peerID })
            // 子機のときは自分を先頭に挿入
            self.listeners.insert(ConnectionController.shared.peerID, at: 0)
        }
        
        if ConnectionController.shared.isDJ! {
            let profile = DefaultsController.shared.profile
            DispatchQueue.global().async {
                DJName = profile.name
                DispatchQueue.main.async {
                    self.DJNameLabel.alpha = 1.0
                    self.DJImageView.alpha = 1.0
                    self.DJStatusLabel.text = "Connecting"
                }
                if let imageUrl = profile.imageUrl {
                    DJIcon = CachedImage.fetch(url: imageUrl)
                    DispatchQueue.main.async {
                        self.DJImageView.image = DJIcon
                        self.DJImageView.setNeedsLayout()
                    }
                }
            }
        } else {
            if let profile = ConnectionController.shared.peerProfileCorrespondence[ConnectionController.shared.connectedDJ!.peerID] {
                DispatchQueue.global().async {
                    DJName = profile.name
                    DispatchQueue.main.async {
                        if ConnectionController.shared.connectedDJ!.state != .connected {
                            self.DJNameLabel.alpha = 0.3
                            self.DJImageView.alpha = 0.3
                            self.DJStatusLabel.text = "Missing"
                        } else {
                            self.DJNameLabel.alpha = 1.0
                            self.DJImageView.alpha = 1.0
                            self.DJStatusLabel.text = "Connecting"
                        }
                    }
                    if let imageUrl = profile.imageUrl {
                        DJIcon = CachedImage.fetch(url: imageUrl)
                        DispatchQueue.main.async{
                            self.DJImageView.image = DJIcon
                            self.DJImageView.setNeedsLayout()
                        }
                    }
                }
            }
        }
        
        // 親機の表示を更新
        DispatchQueue.main.async{
            self.DJNameLabel.text  = DJName
            self.DJImageView.image = DJIcon
            self.tableView.reloadData()
        }
    }
    
    @objc func handlePeerConnectionStateDidUpdate() {
        self.updateMembers()
    }
    
}

// MARK: - UITableViewDataSource

extension MemberViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listeners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        cell.peerName.text       = listeners[indexPath.row].displayName
        cell.peerImageView.image = UIImage(named: "TemporarySingleColored")
        
        // プロフィールが設定されている場合
        DispatchQueue.global().async {
            var listenerName: String?
            var listenerIcon: UIImage?
            if indexPath.row == 0 && !ConnectionController.shared.isDJ! { // 自分自身（子機）
                let profile = DefaultsController.shared.profile
                listenerName = profile.name
                if let imageUrl = profile.imageUrl {
                    listenerIcon = CachedImage.fetch(url: imageUrl)
                }
                DispatchQueue.main.async {
                    cell.peerName.text       = listenerName
                    cell.peerImageView.image = listenerIcon
                    cell.peerImageView.setNeedsLayout()
                }
            } else { // 自分以外の子機
                if let profile = ConnectionController.shared.peerProfileCorrespondence[self.listeners[indexPath.row]] {
                    listenerName = profile.name
                    if let imageUrl = profile.imageUrl {
                        listenerIcon = CachedImage.fetch(url: imageUrl)
                    }
                    DispatchQueue.main.async {
                        cell.peerName.text       = listenerName
                        cell.peerImageView.image = listenerIcon
                        cell.peerImageView.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
    }
 }
