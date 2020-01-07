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
        
        // 中央のタブがある位置に円形のViewを配置
        let centerRoundView = UIView()
        self.tabBar.addSubview(centerRoundView)
        centerRoundView.backgroundColor = UIColor.yusakuBackground
        centerRoundView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(80)
            make.width.equalTo(80)
            make.centerX.equalToSuperview()
            // make.centerY.equalTo(self.tabBar.subviews[1])
            make.top.equalTo(self.tabBar.subviews[1]).offset(-20)
        }
        centerRoundView.layer.cornerRadius = 40
        centerRoundView.clipsToBounds = true
        centerRoundView.layer.borderColor = UIColor.gray.cgColor
        centerRoundView.layer.borderWidth = 0.2
        
        // 円形のViewの枠線を四角いViewで上書きして上側の枠線を残す
        let centerView = UIView()
        self.tabBar.addSubview(centerView)
        centerView.backgroundColor = UIColor.yusakuBackground
        centerView.snp.makeConstraints { [unowned self] (make) -> Void in
            make.width.equalTo(self.tabBar.subviews[1])
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom)
        }
        
        // プラスボタンを中央のエリアに配置
        self.plusButtonView = UIButton()
        self.plusButtonView.backgroundColor = UIColor.yusakuPink
        self.plusButtonView.setImage(UIImage(named: "music.bubble"), for: UIControl.State.normal)
        self.plusButtonView.tintColor = UIColor.white
        self.plusButtonView.addTarget(self, action: #selector(plusButtonTouchDown), for: UIControl.Event.touchDown)
        self.plusButtonView.addTarget(self, action: #selector(plusButtonTouchUp), for: UIControl.Event.touchUpInside)
        self.plusButtonView.addTarget(self, action: #selector(plusButtonTouchUp), for: UIControl.Event.touchUpOutside)
        centerView.addSubview(self.plusButtonView)
        self.plusButtonView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(60)
            make.width.equalTo(60)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(centerRoundView)
        }
        self.plusButtonView.layer.cornerRadius = 30
        self.plusButtonView.clipsToBounds = true
        
        self.requestTabImageView = self.tabBar.subviews[0].subviews.first as? UIImageView
        self.requestTabImageView.contentMode = .center
        
        self.sessionTabImageView = self.tabBar.subviews[2].subviews.first as? UIImageView
        self.sessionTabImageView.contentMode = .center
    }
    
    // tabBarを押した時のバウンドしているアニメーション
    func animateBounce(imageView: UIImageView){ //FIXME: 関数名
        imageView.transform = CGAffineTransform.identity
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: [], animations: {() -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: {() -> Void in
                imageView.transform = CGAffineTransform(scaleX: CGFloat(0.8), y: CGFloat(0.8))
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3, animations: {() -> Void in
                imageView.transform = CGAffineTransform.identity
            })
        }, completion: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tagNumber = TabButtonTagNumber(rawValue: item.tag)
        switch tagNumber {
        case .requests:
            animateBounce(imageView: self.requestTabImageView)
            break
        case .session:
            animateBounce(imageView: self.sessionTabImageView)
            break
        default:
            break
        }
    }
    
    func animateShrinkDown(view: UIView, scale: CGFloat) {
        UIView.animate(withDuration: 0.05, delay: 0.0, animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale);
        }, completion: { _ in
            view.transform = CGAffineTransform(scaleX: scale, y: scale);
        })
    }
    
    func animateGrowUp(view: UIView) {
        UIView.animate(withDuration: 0.05, delay: 0.0, animations: {
            view.transform = CGAffineTransform.identity;
        }, completion: { _ in
            view.transform = CGAffineTransform.identity;
        })
    }
    
    // 中央のプラスボタンが押されたとき
    
    @objc func plusButtonTouchDown() {
        // アニメーション
        self.animateShrinkDown(view: self.plusButtonView, scale: 0.9)
    }
    @objc func plusButtonTouchUp() {
        // アニメーション
        self.animateGrowUp(view: self.plusButtonView)
        
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
