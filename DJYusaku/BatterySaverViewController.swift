//
//  BatterySaverViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/11/19.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class BatterySaverViewController: UIViewController {
    
    @IBOutlet weak var noteView: UIView!
    private var previousScreenBrightness : CGFloat = 0.0    // 元の画面の明るさ
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // シングルタップジェスチャを追加
        let singleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                              action: #selector(handleSingleTapeed(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapGesture)
        
        // ダブルタップジェスチャを追加
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                              action: #selector(handleDoubleTapeed(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
        // シングルタップとダブルタップの両方を有効化
        singleTapGesture.require(toFail: doubleTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 自動スリープをOFFにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        // 元の画面の明るさを記録しておく
        self.previousScreenBrightness = UIScreen.main.brightness
        
        // 注意書きを表示してフェードアウトする
        self.animateFadeOut(view: self.noteView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false    // 自動スリープをONにする
        UIScreen.main.brightness = self.previousScreenBrightness // 画面の明るさを復元する
    }
    
    func animateFadeOut(view: UIView) {
        view.alpha = 1.0
        UIScreen.main.brightness = previousScreenBrightness
        UIView.animate(withDuration: 2.0, delay: 0.0, animations: {
            view.alpha = 0.0
            UIScreen.main.brightness = 0.0
        }, completion: { _ in
            view.alpha = 0.0
            UIScreen.main.brightness = 0.0
        })
    }
    
    // 画面のどこかしらがシングルタップされたら
    @objc func handleSingleTapeed(_ gesture: UITapGestureRecognizer) -> Void {
        // 注意書きを表示してフェードアウトする
        self.animateFadeOut(view: self.noteView)
    }

    // 画面のどこかしらがダブルタップされたら
    @objc func handleDoubleTapeed(_ gesture: UITapGestureRecognizer) -> Void {
        self.dismiss(animated: true)  // Viewを閉じる
    }
    
    // アプリがアクティブになる（例：アプリが他のタスクから復帰する）とき
    @objc func handleDidBecomeActiveNotification() {
        // 自動スリープをOFFにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        // 元の画面の明るさを記録しておく
        self.previousScreenBrightness = UIScreen.main.brightness
        
        // 注意書きを表示してフェードアウトする
        self.animateFadeOut(view: self.noteView)
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
