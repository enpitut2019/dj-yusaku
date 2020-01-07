//
//  UINavigationController+PreferedViewControllerStatusBarColor.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2020/01/04.
//  Copyright © 2020 Yusaku. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let DJYusakuModalViewDidDisappear = Notification.Name("DJYusakuModalViewDidDisappear")
}

extension UINavigationController {
 
    override open var childForStatusBarStyle : UIViewController? {
        return self.visibleViewController
    }

    override open var childForStatusBarHidden: UIViewController? {
        return self.visibleViewController
    }

}
