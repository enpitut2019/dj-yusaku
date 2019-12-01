//
//  TabBarController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/11/30.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import SnapKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        // 中央のタブがある位置に空のViewを配置
        let centerView = UIView()
        self.tabBar.addSubview(centerView)
        centerView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(self.tabBar.subviews[1])
            make.width.equalTo(self.tabBar.subviews[1])
            make.centerX.equalToSuperview()
        }
        
        // プラスボタンを中央のエリアに配置
        let plusButtonView = UIButton()
        plusButtonView.setBackgroundImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 20, weight: UIImage.SymbolWeight.bold, scale: UIImage.SymbolScale.large)),
                                          for: UIControl.State.normal)
        plusButtonView.addTarget(self, action: #selector(plusButton), for: UIControl.Event.touchUpInside)
        centerView.addSubview(plusButtonView)
        plusButtonView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    // 中央のプラスボタンが押されたとき
    @objc func plusButton() {
        // SearchView(実際にはそのコンテナであるNavigation)を表示する
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchNavigation")
        self.present(vc, animated: true)
    }

}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is DummyViewController { return false }   // 中央のタブは無効化しておく
        return true
    }
    
}
