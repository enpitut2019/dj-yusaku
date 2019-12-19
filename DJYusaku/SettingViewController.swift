//
//  SettingViewController.swift
//  DJYusaku
//
//  Created by Masahiro Nakamura on 2019/12/18.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import Swifter
import SafariServices

class SettingViewController: UIViewController, SFSafariViewControllerDelegate {
    private var swifter = Swifter(
        consumerKey: Secrets.TwitterConsumerKey,
        consumerSecret: Secrets.TwitterConsumerSecret
    )
    
    private var screenName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginTwitter(_ sender: Any) {
        let url = URL(string: "swifter://success")!
        swifter.authorize(withCallback: url, presentingFrom: self, success: { [unowned self] token, _ in
            if token != nil {
                self.screenName = token!.screenName
            }
            // ユーザーのプロフィール情報を取得して設定する
            self.swifter.showUser(.screenName(self.screenName!), success: { json in
                let imageUrlString = json["profile_image_url_https"].string!.replacingOccurrences(of: "_normal", with: "", options: .backwards)
                let profile = PeerProfile(name:     json["name"].string!,
                                          imageUrl: URL(string: imageUrlString)!)
                ConnectionController.shared.setProfile(profile: profile)
                NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
                // プロフィールを他のピアに送信する
                let data = try! JSONEncoder().encode(profile)
                let messageData = try! JSONEncoder().encode(MessageData(desc:  MessageData.DataType.peerProfile, value: data))
                ConnectionController.shared.session.sendRequest(messageData, toPeers: ConnectionController.shared.session.connectedPeers, with: .unreliable)
            }, failure: { error in
                self.alert(title: "Error", message: error.localizedDescription)
            })
        }, failure: { error in
            self.alert(title: "Error", message: error.localizedDescription)
        })
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
