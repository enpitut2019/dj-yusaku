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
    
    static private var isViewAppearedAtLeastOnce: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !ConnectionController.shared.isInitialized {
            ConnectionController.shared.initialize()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ConnectionController.shared.isDJ != nil {
            self.doneButtonItem.isEnabled = true
        } else {
            self.doneButtonItem.isEnabled = false
        }
    }

    @IBAction func closeModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinAsDJ(_ sender: Any) {
        ConnectionController.shared.startDJ()
        
        self.dismiss(animated: true, completion: nil)
    }
}
