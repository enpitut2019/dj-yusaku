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
