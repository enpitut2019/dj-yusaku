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
    @IBOutlet weak var willUseTwitterProfileSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.userNameLabel.text = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.ProfileName)
        
        self.willUseTwitterProfileSwitch.isOn = DefaultsController.shared.willUseTwitterProfile
        
        if let twitterAccount = DefaultsController.shared.twitterAccount {
            self.twitterAccountLabel.text = "@" + twitterAccount.screenName
        }
        
    }
    
    
    @IBAction func willUseTwitterProfileSwitchValueDidChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaults.DJYusakuDefaults.WillUseTwitterProfile)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)  // セルの選択を解除
        switch indexPath.section {
        case 0: // Your Profile
            break
        case 1: // Twitter
            self.tableViewTwitterSection(at: indexPath.row)
        case 2: // About This App
            break
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
                guard let token = token else { return }
                // ログイン状態を保存する
                let twitterAccount = TwitterAccount(key:        token.key,
                                                    secret:     token.secret,
                                                    screenName: token.screenName!)
                let data = try! JSONEncoder().encode(twitterAccount)
                UserDefaults.standard.set(data, forKey: UserDefaults.DJYusakuDefaults.TwitterAccount)
            }, failure: { error in
                print("Swifter Error at SettingsViewController.tableViewTwitterSection():", error.localizedDescription)
            })
        default:
          break
        }
    }
}

// MARK: - SettingsNameViewController

class SettingsNameViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 既に名前が設定されていればテキストボックスに名前を表示
        self.nameField.text = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.ProfileName)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameField.resignFirstResponder()
        
        if let name = self.nameField.text {
            UserDefaults.standard.set(name, forKey: UserDefaults.DJYusakuDefaults.ProfileName)
        }

        return true
    }
}

// MARK: - SettingsAboutThisAppViewController

class SettingsAboutThisAppViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let developerGitHubLinks = [
        URL(string: "https://github.com/yaplus")!,      // yaplus
        URL(string: "https://github.com/amylaseF85")!,  // amylaseF85
        URL(string: "https://github.com/tsuu32")!,      // tsuu32
        URL(string: "https://github.com/bldsky")!       // bldsky
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)  // セルの選択を解除
        switch indexPath.section {
        case 0: // Version
            break
        case 1: // About Us
            let url = self.developerGitHubLinks[indexPath.row]
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
    
}
