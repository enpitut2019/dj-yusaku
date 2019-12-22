//
//  DefaultsController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/12/22.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import Swifter

struct TwitterAccount {
    var key:        String
    var secret:     String
    var screenName: String
    
    init(key: String, secret: String, screenName: String) {
        self.key        = key
        self.secret     = secret
        self.screenName = screenName
    }
}

class DefaultsController: NSObject {
    static let shared = DefaultsController()
    
    public private(set) var twitterAccount: TwitterAccount? = nil
    public private(set) var swifter : Swifter = Swifter(consumerKey: Secrets.TwitterConsumerKey,
                                                        consumerSecret: Secrets.TwitterConsumerSecret)
    
    public private(set) var profile: PeerProfile? = nil
    
    private override init() {
        super.init()
        
        // ログイン状態が保存されていればプロフィールを取得する
        self.setupTwitterAccount()
        self.setProfileFromTwitter()
    }

    func setupTwitterAccount() {
        if let twitterKey        = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.TwitterKey)
         , let twitterSecret     = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.TwitterSecret)
         , let twitterScreenName = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.TwitterScreenName) {
            self.twitterAccount = TwitterAccount(key: twitterKey, secret: twitterSecret, screenName: twitterScreenName)
            self.swifter = Swifter(consumerKey:      Secrets.TwitterConsumerKey,
                                   consumerSecret:   Secrets.TwitterConsumerSecret,
                                   oauthToken:       self.twitterAccount!.key,
                                   oauthTokenSecret: self.twitterAccount!.secret)
        }
    }
    
    func setProfileFromTwitter(currentViewController: UIViewController? = nil,
                               completion: (() -> (Void))? = nil) {
        guard let twitterAccount = self.twitterAccount else { return }
        // ユーザーのプロフィール情報を取得して設定する
        self.swifter.showUser(.screenName(twitterAccount.screenName), success: { json in
            let imageUrlString = json["profile_image_url_https"].string!.replacingOccurrences(of: "_normal", with: "", options: .backwards)
            self.profile = PeerProfile(name: json["name"].string!,
                                       imageUrl: URL(string: imageUrlString)!)
            if let completion = completion { completion() }
        }, failure: { error in
            guard let viewController = currentViewController else {
                print(error.localizedDescription)
                return
            }
            let alert = UIAlertController(title: "Error",
                                          message: error.localizedDescription,
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true)
        })
    }
    
}
