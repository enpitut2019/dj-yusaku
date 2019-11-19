//
//  BatterySaverViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/11/19.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class BatterySaverViewController: UIViewController {

    private var previousScreenBrightness : CGFloat = 0.0    // 元の画面の明るさ
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 自動スリープをOFFにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        // 画面の明るさを最低にする
        previousScreenBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 0.0
    }

    // 画面のどこかしらがタッチされたら
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.isIdleTimerDisabled = false    // 自動スリープをONにする
        UIScreen.main.brightness = previousScreenBrightness // 画面の明るさを復元する
        self.dismiss(animated: true)                        // Viewを閉じる
    }
    
    // ホームインジケータ(iPhone X以降)を非表示にする
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // ステータスバーを非表示にする
    override var prefersStatusBarHidden: Bool {
        return true
    }
 
}
