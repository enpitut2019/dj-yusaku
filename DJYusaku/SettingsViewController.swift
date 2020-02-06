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

// SFSafariViewControllerが閉じた後にステータスバーの色を戻す必要がある
extension SFSafariViewController {
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: .DJYusakuModalViewDidDisappear, object: nil)
    }
}

class SettingsViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var twitterAccountLabel: UILabel!
    @IBOutlet weak var willUseTwitterProfileSwitch: UISwitch!
    @IBOutlet weak var isAutoLockEnabledSwitch: UISwitch!
    @IBOutlet weak var isNowPlayingDisplayEnabledSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalViewDidDisappear), name: .DJYusakuModalViewDidDisappear, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.userNameLabel.text = UserDefaults.standard.string(forKey: UserDefaults.DJYusakuDefaults.ProfileName)
        
        self.willUseTwitterProfileSwitch.isEnabled = DefaultsController.shared.twitterAccount != nil
        if self.willUseTwitterProfileSwitch.isEnabled {
            self.willUseTwitterProfileSwitch.isOn = DefaultsController.shared.willUseTwitterProfile
        }
        
        if let twitterAccount = DefaultsController.shared.twitterAccount {
            self.twitterAccountLabel.text = "@" + twitterAccount.screenName
        }
        
        self.isAutoLockEnabledSwitch.isOn = DefaultsController.shared.isAutoLockEnabled
        
        self.tableView.reloadData()
    }
    
    @IBAction func willUseTwitterProfileSwitchValueDidChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaults.DJYusakuDefaults.WillUseTwitterProfile)
    }
    
    @IBAction func isAutoLockEnabledSwitchValueDidChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaults.DJYusakuDefaults.IsAutoLockEnabled)
    }
    @IBAction func isNowPlayingDisplayEnabledSwitchValueDidChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaults.DJYusakuDefaults.IsNowPlayingDisplayEnabled)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc func handleModalViewDidDisappear() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)  // セルの選択を解除
        switch indexPath.section {
        case 0: // Your Profile
            break
        case 1: // Twitter
            self.tableViewTwitterSection(at: indexPath.row)
        case 2: // Auto-Lock
            break
        case 3: // NowPlaying
            break
        case 4: // About This App
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
                self.twitterAccountLabel.text = "@" + twitterAccount.screenName
                self.willUseTwitterProfileSwitch.isEnabled = true
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameField.resignFirstResponder()
        
        let name = self.nameField.text ?? ""
        if name.isEmpty {
            UserDefaults.standard.removeObject(forKey: UserDefaults.DJYusakuDefaults.ProfileName)
        } else {
            UserDefaults.standard.set(name, forKey: UserDefaults.DJYusakuDefaults.ProfileName)
        }

        return true
    }
    
}

// MARK: - SettingsAboutThisAppViewController

class SettingsAboutThisAppViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let developerGitHubLinks = [
        URL(string: "https://github.com/yaplus")!,      // yaplus
        URL(string: "https://github.com/amylaseF85")!,  // amylaseF85
        URL(string: "https://github.com/tsuu32")!,      // tsuu32
        URL(string: "https://github.com/bldsky")!       // bldsky
    ]

    let repositoryLink = URL(string: "https://github.com/enpitut2019/dj-yusaku")!
    
    let designerLink = URL(string: "https://yaplus.jp/")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalViewDidDisappear), name: .DJYusakuModalViewDidDisappear, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc func handleModalViewDidDisappear() {
        self.setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)  // セルの選択を解除
        switch indexPath.section {
        case 0: // Version
            break
        case 1: // Repository
            let url = self.repositoryLink
            let safariView = SFSafariViewController(url: url)
            self.present(safariView, animated: true, completion: nil)
        case 2: // Developer
            let url = self.developerGitHubLinks[indexPath.row]
            let safariView = SFSafariViewController(url: url)
            self.present(safariView, animated: true, completion: nil)
        case 3: // Designer
            let url = self.designerLink
            let safariView = SFSafariViewController(url: url)
            self.present(safariView, animated: true, completion: nil)
        default:
            break
        }
    }
    
}
