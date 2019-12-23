//
//  DefaultsController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/12/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import Swifter

struct TwitterAccount: Codable {
    var key:        String
    var secret:     String
    var screenName: String
    
    init(key: String, secret: String, screenName: String) {
        self.key        = key
        self.secret     = secret
        self.screenName = screenName
    }
}

//
// DefaultsController
//  - UserDefaultsの内容に合わせて自身の状態を更新する
//

class DefaultsController: NSObject {
    static let shared = DefaultsController()
    
    private(set) var twitterAccount: TwitterAccount? = nil
    private(set) var swifter : Swifter = Swifter(consumerKey: Secrets.TwitterConsumerKey,
                                                 consumerSecret: Secrets.TwitterConsumerSecret)
    private(set) var profile: PeerProfile? = nil
    private(set) var willUseTwitterProfile : Bool = false
    
    private override init() {
        super.init()
        // UserDefaultsの変更を監視する
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleUserDefaultsDidChange),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
        self.update()
    }
    
    // UserDefaultsから設定を取得する
    private func update() {
        // プロフィールを初期化する
        self.profile = PeerProfile(name: UIDevice.current.name, imageUrl: nil)
        
        // プロフィールの名前を設定する
        if let name = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.ProfileName) {
            self.profile = PeerProfile(name: name, imageUrl: nil)
        }
        
        // Twitterのプロフィールを使用するかどうかを設定する
        self.willUseTwitterProfile = UserDefaults.standard.bool(forKey: UserDefaults.DJYusakuDefaults.WillUseTwitterProfile)
        
        // Twitterアカウントを設定する
        self.updateTwitterAccount() { [unowned self] in
            if self.willUseTwitterProfile { // Twitterの情報をプロフィールに反映するとき
                // プロフィールをTwitterの情報で上書きする
                self.updateProfileFromTwitter() {
                    self.sendProfile()  // Swifterが別スレッドで処理するため、プロフィールをもう一回送る
                }
            }
        }
        
        self.sendProfile()  // プロフィールを他のピアに送信する
    }
    
    // プロフィールを他のピアに送信する
    private func sendProfile() {
        if let profile = self.profile {
            let data = try! JSONEncoder().encode(profile)
            let messageData = try! JSONEncoder().encode(MessageData(desc: MessageData.DataType.peerProfile, value: data))
            ConnectionController.shared.session.sendRequest(messageData,
                                                            toPeers: ConnectionController.shared.session.connectedPeers,
                                                            with: .unreliable)
            NotificationCenter.default.post(name: .DJYusakuPeerConnectionStateDidUpdate, object: nil)
        }
    }
    
    @objc func handleUserDefaultsDidChange(_ notification: Notification) {
        self.update()
    }

    private func updateTwitterAccount(completion: (() -> (Void))? = nil) {
        if let data = UserDefaults.standard.data(forKey: UserDefaults.DJYusakuDefaults.TwitterAccount) {
            self.twitterAccount = try! JSONDecoder().decode(TwitterAccount.self, from: data)
            self.swifter = Swifter(consumerKey:      Secrets.TwitterConsumerKey,
                                   consumerSecret:   Secrets.TwitterConsumerSecret,
                                   oauthToken:       self.twitterAccount!.key,
                                   oauthTokenSecret: self.twitterAccount!.secret)
            if let completion = completion { completion() }
        }
    }
    
    private func updateProfileFromTwitter(completion: (() -> (Void))? = nil) {
        guard let twitterAccount = self.twitterAccount else { return }
        // ユーザーのプロフィール情報を取得して設定する
        self.swifter.showUser(.screenName(twitterAccount.screenName), success: { json in
            let imageUrlString = json["profile_image_url_https"].string!.replacingOccurrences(of: "_normal", with: "", options: .backwards)
            self.profile = PeerProfile(name: json["name"].string!,
                                       imageUrl: URL(string: imageUrlString))
            if let completion = completion { completion() }
        }, failure: { error in
            print("Swifter Error at DefaultsController.updateProfileFromTwitter():", error.localizedDescription)
        })
    }
    
}
