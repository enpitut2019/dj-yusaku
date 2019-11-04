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
        
        // Debug用
        if (MCConnecter.shared.initialized && !MCConnecter.shared.isParent) {
            print(MCConnecter.shared.session.connectedPeers)
            do {
                let debugData = Data([0x44, 0x4A])
                print(debugData)
                try MCConnecter.shared.session.send(debugData, toPeers: [MCConnecter.shared.connectedDJ], with: .unreliable)
            } catch {
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.doneButtonItem.isEnabled = self.isModalInPresentation
    }
    
    @IBAction func joinAsDJ(_ sender: Any) {
        if (!MCConnecter.shared.initialized) {
            MCConnecter.shared.initialize(isParent: true, displayName: UIDevice.current.name)
        }
        MCConnecter.shared.startAdvertise()
        self.dismiss(animated: true, completion: nil)
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
    
}

// MARK: - MCConnecterDelegate
extension WelcomeViewController: MCConnecterDelegate {
    // データが送られてきたときに実行される関数
    func mcConnecter(didReceiveData data: Data, from peerID: MCPeerID) {
        print("\(peerID)から \(String(data: data, encoding: .utf8)!)を受け取りました")
    }
    
    func mcConnecter(connectableDevicesChanged devices: [MCPeerID]) {
        
    }
}
