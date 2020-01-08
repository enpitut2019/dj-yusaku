//
//  WelcomeViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/27.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var joinTheSessionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーの見た目を設定
        self.navigationController?.navigationBar.shadowImage = UIImage()    // 下線を消す
        
        if !ConnectionController.shared.isInitialized {
            ConnectionController.shared.initialize()
        }
        
        self.newSessionButton.layer.cornerRadius = 6
        self.newSessionButton.clipsToBounds = true
        self.newSessionButton.layer.borderColor = UIColor.yusakuPink?.cgColor
        self.newSessionButton.layer.borderWidth = 1.5
        
        self.joinTheSessionButton.layer.cornerRadius = 6
        self.joinTheSessionButton.clipsToBounds = true
        self.joinTheSessionButton.layer.borderColor = UIColor.yusakuPink?.cgColor
        self.joinTheSessionButton.layer.borderWidth = 1.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 初回起動の際にはTutorialViewControllerを表示する
        let isLaunchedAtLeastOnce = UserDefaults.standard.bool(forKey: UserDefaults.DJYusakuDefaults.IsLaunchedAtLeastOnce)
        if !isLaunchedAtLeastOnce {
            // 起動済みであることをUserDefaultsに保存（DefaultsControllerを通さないことに注意）
            UserDefaults.standard.set(true, forKey: UserDefaults.DJYusakuDefaults.IsLaunchedAtLeastOnce)
            // モーダルでチュートリアルを表示
            let storyboard: UIStoryboard = self.storyboard!
            let tutorialViewController = storyboard.instantiateViewController(withIdentifier: "TutorialView")
            tutorialViewController.isModalInPresentation = true
            self.present(tutorialViewController, animated: true)
        }
        
        if ConnectionController.shared.isDJ != nil {
            self.doneButtonItem.isEnabled = true
        } else {
            self.doneButtonItem.isEnabled = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: .DJYusakuModalViewDidDisappear, object: nil)
    }

    @IBAction func closeModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinAsDJ(_ sender: Any) {
        ConnectionController.shared.startDJ()
        
        self.dismiss(animated: true, completion: nil)
    }
}
