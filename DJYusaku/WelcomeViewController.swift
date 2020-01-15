//
//  WelcomeViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/27.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import StoreKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var joinTheSessionButton: UIButton!
    
    private let cloudServiceController = SKCloudServiceController()
    
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
        // Apple Musicライブラリへのアクセス許可の確認
        SKCloudServiceController.requestAuthorization { status in
            guard status == .authorized else { return }
            
            defer {
                DispatchQueue.main.async {
                    ConnectionController.shared.startDJ()
                    self.dismiss(animated: true)
                }
            }
            
            // Apple Musicの曲が再生可能か確認
            self.cloudServiceController.requestCapabilities { [unowned self] (capabilities, error) in
                guard error == nil && capabilities.contains(.musicCatalogPlayback) else {
                    // アラートを表示
                    let title = capabilities.contains(.musicCatalogPlayback)
                              ? "Apple Music membership could not be confirmed"
                              : "Could not connect to Apple Music"
                    let message = capabilities.contains(.musicCatalogPlayback)
                                ? "Apple Music songs are not played in this session."
                                : "Please check your online status."
                    let alertController = UIAlertController(title: title.localized,
                                                            message: message.localized,
                                                            preferredStyle: .alert)
                    let alertButton = UIAlertAction(title: "OK", style: .cancel)
                    alertController.addAction(alertButton)
                    DispatchQueue.main.async {
                        self.presentingViewController?.present(alertController, animated: true)
                    }
                    return
                }
            }
        }
    }
}
