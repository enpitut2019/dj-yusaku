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
                                                                              action:#selector(handleDoubleTapeed(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // アラートを表示
        let alertController = UIAlertController(title:   "Batter Saver Mode",
                                                message: "To exit battery saver mode, double-tap the screen.",
                                                preferredStyle: UIAlertController.Style.alert)
        let alertButton = UIAlertAction(title: "OK",
                                        style: UIAlertAction.Style.cancel,
                                        handler: { [unowned self] (action: UIAlertAction!) -> Void in
                                            // 自動スリープをOFFにする
                                            UIApplication.shared.isIdleTimerDisabled = true
                                            
                                            // 画面の明るさを最低にする
                                            self.previousScreenBrightness = UIScreen.main.brightness
                                            UIScreen.main.brightness = 0.0
                                        })
        alertController.addAction(alertButton)
        self.present(alertController, animated: true, completion: nil)
        

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
    
    // ホームインジケータ(iPhone X以降)を非表示にする
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // ステータスバーを非表示にする
    override var prefersStatusBarHidden: Bool {
        return true
    }
 
}
