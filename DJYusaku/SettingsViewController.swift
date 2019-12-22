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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginTwitter(_ sender: Any) {
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
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
