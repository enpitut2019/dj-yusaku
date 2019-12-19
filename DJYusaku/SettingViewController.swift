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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginTwitter(_ sender: Any) {
        let failureHandler: (Error) -> Void = { error in
            self.alert(title: "Error", message: error.localizedDescription)
        }
        
        let url = URL(string: "swifter://success")!
        swifter.authorize(withCallback: url, presentingFrom: self, success: { token, _ in
            if token != nil {
                self.screenName = token!.screenName
            }
            self.getUserAvatorUrl()
        }, failure: failureHandler)
    }

    func getUserAvatorUrl() {
        let failureHandler: (Error) -> Void = { error in
            self.alert(title: "Error", message: error.localizedDescription)
        }
        
        swifter.showUser(.screenName(self.screenName!), success: { json in
            print(json["profile_image_url_https"])
            ConnectionController.shared.setIconURL(iconURL: URL(string: json["profile_image_url_https"].string!))
            print(ConnectionController.shared.iconURL!)
        }, failure: failureHandler)
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
