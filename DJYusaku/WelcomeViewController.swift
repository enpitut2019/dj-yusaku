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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.doneButtonItem.isEnabled = self.isModalInPresentation
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func closeModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinAsDJ(_ sender: Any) {
        ConnectionController.shared.initialize(isParent: true, displayName: UIDevice.current.name)
        
        ConnectionController.shared.startAdvertise()
        
        self.dismiss(animated: true, completion: nil)
    }
}
