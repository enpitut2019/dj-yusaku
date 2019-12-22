//
//  SettingsViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/12/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import Swifter
import SafariServices

class SettingsViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var twitterAccountLabel: UILabel!
    
    let developerGitHubLinks = [
        URL(string: "https://github.com/yaplus")!,      // yaplus
        URL(string: "https://github.com/amylaseF85")!,  // amylaseF85
        URL(string: "https://github.com/tsuu32")!,      // tsuu32
        URL(string: "https://github.com/bldsky")!       // bldsky
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let profile = DefaultsController.shared.profile {
            self.userNameLabel.text = profile.name
        }
        
        if let twitterAccount = DefaultsController.shared.twitterAccount {
            self.twitterAccountLabel.text = "@" + twitterAccount.screenName
        }
        
    }
    
}

// MARK: - UITableViewDelegate

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)  // セルの選択を解除
        switch indexPath.section {
        case 0: // Your Profile
            break
        case 1: // Twitter
            self.tableViewTwitterSection(at: indexPath.row)
        case 2: // About Us
            let url = self.developerGitHubLinks[indexPath.row]
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
    
    func tableViewTwitterSection(at index: Int) {
        switch index {
        case 0: // Your Profile
            // Twitterにログインする
            let url = URL(string: "swifter://success")!
            DefaultsController.shared.swifter.authorize(withCallback: url, presentingFrom: self, success: { token, _ in
                guard token != nil else { return }
                // ログイン状態を保存する
                UserDefaults.standard.set(token?.key,         forKey: UserDefaults.DJYusakuDefaults.TwitterKey)
                UserDefaults.standard.set(token?.secret,      forKey: UserDefaults.DJYusakuDefaults.TwitterSecret)
                UserDefaults.standard.set(token!.screenName!, forKey: UserDefaults.DJYusakuDefaults.TwitterScreenName)
                DefaultsController.shared.setupTwitterAccount()
                DefaultsController.shared.setProfileFromTwitter(currentViewController: self) {
                    // プロフィールを他のピアに送信する
                    let data = try! JSONEncoder().encode(DefaultsController.shared.profile!)
                    let messageData = try! JSONEncoder().encode(MessageData(desc: MessageData.DataType.peerProfile, value: data))
                    ConnectionController.shared.session.sendRequest(messageData,
                                                                    toPeers: ConnectionController.shared.session.connectedPeers,
                                                                    with: .unreliable)
                    NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
                }
            }, failure: { error in
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        default:
          break
        }
    }
}
