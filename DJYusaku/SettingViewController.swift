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
    private var swifter : Swifter = Swifter(consumerKey: Secrets.TwitterConsumerKey,
                                            consumerSecret: Secrets.TwitterConsumerSecret)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ログイン状態が保存されていればプロフィールを取得する
        if let twitterKey        = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.TwitterKey)
         , let twitterSecret     = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.TwitterSecret)
         , let twitterScreenName = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.TwitterScreenName) {
            swifter = Swifter(consumerKey: Secrets.TwitterConsumerKey,
                              consumerSecret: Secrets.TwitterConsumerSecret,
                              oauthToken: twitterKey,
                              oauthTokenSecret: twitterSecret)
            // プロフィールを取得する
            print(twitterScreenName)
            self.getProfile(screenName: twitterScreenName)
        }
    }
    
    @IBAction func loginTwitter(_ sender: Any) {
        let url = URL(string: "swifter://success")!
        swifter.authorize(withCallback: url, presentingFrom: self, success: { [unowned self] token, _ in
            guard token != nil else { return }
            // ログイン状態を保存する
            UserDefaults.standard.set(token?.key,         forKey: UserDefaults.DJYusakuDefaults.TwitterKey)
            UserDefaults.standard.set(token?.secret,      forKey: UserDefaults.DJYusakuDefaults.TwitterSecret)
            UserDefaults.standard.set(token!.screenName!, forKey: UserDefaults.DJYusakuDefaults.TwitterScreenName)

            self.getProfile(screenName: token!.screenName!)
        }, failure: { error in
            self.alert(title: "Error", message: error.localizedDescription)
        })
    }
    
    func getProfile(screenName: String) {
        
        // ユーザーのプロフィール情報を取得して設定する
        self.swifter.showUser(.screenName(screenName), success: { json in
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
