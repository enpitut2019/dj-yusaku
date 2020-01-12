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
    @IBOutlet weak var DJImageContainerView: UIView!
    @IBOutlet weak var DJStatusLabel: UILabel!
    @IBOutlet weak var noListenersView: UIView!
    @IBOutlet weak var numberOfParticipantsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーの見た目を設定
        self.navigationController?.navigationBar.shadowImage = UIImage()    // 下線を消す
        
        // tableViewのdataSource設定
        tableView.dataSource = self
        
        // 参加人数表示の見た目を設定（角丸・影・境界線など）
        numberOfParticipantsLabel.layer.cornerRadius = numberOfParticipantsLabel.frame.size.height * 0.5
        numberOfParticipantsLabel.clipsToBounds = true
        
        // DJのアイコン画像の見た目を設定（角丸・影・境界線など）
        DJImageContainerView.layer.cornerRadius = DJImageContainerView.frame.size.height * 0.5
        DJImageContainerView.layer.shadowColor      = UIColor.black.cgColor
        DJImageContainerView.layer.shadowOffset     = CGSize(width: 0, height: 3)
        DJImageContainerView.layer.shadowOpacity    = 0.4
        DJImageView.layer.cornerRadius = DJImageView.frame.size.height * 0.5
        DJImageView.clipsToBounds = true
        
        noListenersView.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePeerConnectionStateDidUpdate), name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalViewDidDisappear), name: .DJYusakuModalViewDidDisappear, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateMembers()
    }
    
    func updateMembers() {
        guard let isDJ = ConnectionController.shared.isDJ else { return }
        var DJName: String?
        var DJImage: UIImage?
        
        self.listeners = ConnectionController.shared.session.connectedPeers
        
        if isDJ {
            DJName = DefaultsController.shared.profile.name
            
            DispatchQueue.global().async {
                if let imageUrl = DefaultsController.shared.profile.imageUrl {
                    DJImage = CachedImage.fetch(url: imageUrl)
                }
                DispatchQueue.main.async {
                    self.DJImageView.image = DJImage ?? UIImage(named: "TemporarySingleColored")
                    self.DJImageView.setNeedsLayout()
                }
            }
            DispatchQueue.main.async {
                self.DJNameLabel.alpha = 1.0
                self.DJImageView.alpha = 1.0
                self.DJStatusLabel.text = "You".localized
            }
        } else {
            guard let connectedDJ = ConnectionController.shared.connectedDJ else { return }
            if let DJProfile = ConnectionController.shared.peerProfileCorrespondence[connectedDJ.peerID] {
                DJName = DJProfile.name
                
                DispatchQueue.global().async {
                    if let imageUrl = DJProfile.imageUrl {
                        DJImage = CachedImage.fetch(url: imageUrl)
                    }
                    DispatchQueue.main.async {
                        self.DJImageView.image = DJImage ?? UIImage(named: "TemporarySingleColored")
                        self.DJImageView.setNeedsLayout()
                    }
                }
            } else {
                DJName = connectedDJ.peerID.displayName

                DispatchQueue.main.async {
                    self.DJImageView.image = UIImage(named: "TemporarySingleColored")
                    self.DJImageView.setNeedsLayout()
                }
            }
            DispatchQueue.main.async {
                if connectedDJ.state != .connected {
                    self.DJNameLabel.alpha = 0.3
                    self.DJImageView.alpha = 0.3
                    self.DJStatusLabel.text = "Missing".localized
                } else {
                    self.DJNameLabel.alpha = 1.0
                    self.DJImageView.alpha = 1.0
                    self.DJStatusLabel.text = "Connecting".localized
                }
            }
            
            // 接続している端末（親機）はtableViewには表示しない
            self.listeners = self.listeners.filter({ $0 != connectedDJ.peerID })
            // 子機のときは自分を先頭に挿入
            self.listeners.insert(ConnectionController.shared.peerID, at: 0)
        }
        
        // 親機の表示を更新
        DispatchQueue.main.async {
            self.DJNameLabel.text  = DJName
            self.noListenersView.isHidden = !self.listeners.isEmpty
            self.numberOfParticipantsLabel.text = "\(ConnectionController.shared.numberOfParticipants)/8"
            self.tableView.reloadData()
        }
    }
    
    @objc func handlePeerConnectionStateDidUpdate() {
        self.updateMembers()
    }
    
    @objc func handleModalViewDidDisappear() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

// MARK: - UITableViewDataSource

extension MemberViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard ConnectionController.shared.isDJ != nil else { return 0 }
        return self.listeners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        guard let isDJ = ConnectionController.shared.isDJ else { return cell }
        var listenerImage: UIImage?
        if indexPath.row == 0 && !isDJ { // 自分自身（子機）
            let profile = DefaultsController.shared.profile
            cell.peerName.text = profile.name
            cell.statusView.isHidden = false
            DispatchQueue.global().async {
                if let imageUrl = profile.imageUrl {
                    listenerImage = CachedImage.fetch(url: imageUrl)
                }
                DispatchQueue.main.async {
                    cell.peerImageView.image = listenerImage ?? UIImage(named: "TemporarySingleColored")
                    cell.peerImageView.setNeedsLayout()
                }
            }
        } else { // 自分以外の子機
            if let profile = ConnectionController.shared.peerProfileCorrespondence[self.listeners[indexPath.row]] {
                cell.peerName.text = profile.name
                cell.statusView.isHidden = true
                DispatchQueue.global().async {
                    if let imageUrl = profile.imageUrl {
                        listenerImage = CachedImage.fetch(url: imageUrl)
                    }
                    DispatchQueue.main.async {
                        cell.peerImageView.image = listenerImage ?? UIImage(named: "TemporarySingleColored")
                        cell.peerImageView.setNeedsLayout()
                    }
                }
            } else { // このリスナーのprofileをまだ受け取ってないとき
                cell.peerName.text = self.listeners[indexPath.row].displayName
            }
            
        }
        return cell
    }
 }
