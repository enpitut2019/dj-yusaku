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
        
        // ダブルタップジェスチャを追加
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                              action: #selector(handleDoubleTapeed(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 自動スリープをOFFにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        // 画面の明るさを最低にする
        self.previousScreenBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 0.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false    // 自動スリープをONにする
        UIScreen.main.brightness = previousScreenBrightness // 画面の明るさを復元する
    }

    // 画面のどこかしらがダブルタップされたら
    @objc func handleDoubleTapeed(_ gesture: UITapGestureRecognizer) -> Void {
        self.dismiss(animated: true)  // Viewを閉じる
    }
    
    // アプリがアクティブになる（例：アプリが他のタスクから復帰する）とき
    @objc func handleDidBecomeActiveNotification() {
        // 自動スリープをOFFにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        // 画面の明るさを最低にする
        self.previousScreenBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 0.0
    }
    
    // アプリがアクティブじゃなくなる（例：ホーム画面に戻る）とき
    @objc func handleWillResignActiveNotification() {
        UIApplication.shared.isIdleTimerDisabled = false    // 自動スリープをONにする
        UIScreen.main.brightness = previousScreenBrightness // 画面の明るさを復元する
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
