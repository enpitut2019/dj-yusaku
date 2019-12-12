//
//  TabBarController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/11/30.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import SnapKit

enum TabButtonTagNumber: Int{
    case requests   = 0
    case plusButton = 1
    case session    = 2
}

class TabBarController: UITabBarController {
    
    var requestTabImageView:  UIImageView!
    var sessionTabImageView:  UIImageView!
    var plusButtonView: UIButton!

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
        self.plusButtonView = UIButton()
        self.plusButtonView.setBackgroundImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 20, weight: UIImage.SymbolWeight.bold, scale: UIImage.SymbolScale.large)),
                                          for: UIControl.State.normal)
        self.plusButtonView.addTarget(self, action: #selector(plusButton), for: UIControl.Event.touchUpInside)
        centerView.addSubview(self.plusButtonView)
        self.plusButtonView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.requestTabImageView = self.tabBar.subviews[0].subviews.first as? UIImageView
        self.requestTabImageView.contentMode = .center
        
        self.sessionTabImageView = self.tabBar.subviews[2].subviews.first as? UIImageView
        self.sessionTabImageView.contentMode = .center
    }
    
    //tabBarを押した時のバウンドしているアニメーション
    func bounceAnimation(tabImageView: UIImageView){ //FIXME: 関数名
        tabImageView.transform = CGAffineTransform.identity
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: [], animations: {() -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: {() -> Void in
                tabImageView.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3, animations: {() -> Void in
                tabImageView.transform = CGAffineTransform.identity
            })
        }, completion: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tagNumber = TabButtonTagNumber(rawValue: item.tag)
        switch tagNumber {
        case .requests:
            bounceAnimation(tabImageView: self.requestTabImageView)
            break
        case .session:
            bounceAnimation(tabImageView: self.sessionTabImageView)
            break
        default:
            break
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
