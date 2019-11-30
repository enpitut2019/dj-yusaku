//
//  DummyViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/11/30.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class DummyViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchNavigation")
        self.present(vc, animated: true)
    }
}
