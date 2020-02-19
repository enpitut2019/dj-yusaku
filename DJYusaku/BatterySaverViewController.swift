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
    @IBOutlet weak var nowPlayingArtwork: UIImageView!
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleNowPlayingItemDidChange), name: .DJYusakuPlayerQueueNowPlayingSongDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 自動スリープをOFFにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        // 元の画面の明るさを記録しておく
        self.previousScreenBrightness = UIScreen.main.brightness
        
        if(PlayerQueue.shared.isQueueCreated && DefaultsController.shared.isNowPlayingDisplayEnabled){
            updateNowPlaying()
            nowPlayingArtwork.alpha = 1.0
            nowPlayingTitle.alpha   = 1.0
            nowPlayingArtist.alpha  = 1.0
        }else{
            nowPlayingArtwork.alpha = 0.0
            nowPlayingTitle.alpha   = 0.0
            nowPlayingArtist.alpha  = 0.0
        }
        
        // 注意書きを表示してフェードアウトする
        self.animateFadeOut(view: self.noteView, delay: 1.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 自動スリープをONにする
        UIApplication.shared.isIdleTimerDisabled = !DefaultsController.shared.isAutoLockEnabled
        
        UIScreen.main.brightness = self.previousScreenBrightness // 画面の明るさを復元する
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: .DJYusakuModalViewDidDisappear, object: nil)
    }
    
    func animateFadeOut(view: UIView, delay: Double) {
        view.alpha = 1.0
        UIScreen.main.brightness = previousScreenBrightness
        UIView.animate(withDuration: 2.0, delay: delay, animations: {
            view.alpha = 0.0
        }, completion: { finished in
            if finished {
                view.alpha = 0.0
                UIScreen.main.brightness = 0.0
            }
        })
    }
    
    private func updateNowPlaying(){
        let indexNowPlayingItem = PlayerQueue.shared.mpAppController.indexOfNowPlayingItem;
        if let nowPlayingSong = PlayerQueue.shared.get(at: indexNowPlayingItem) {
            DispatchQueue.global().async {
                let image = CachedImage.fetch(url: nowPlayingSong.artworkUrl)
                DispatchQueue.main.async {
                    self.nowPlayingArtwork.image = image
                    self.nowPlayingTitle.text  = nowPlayingSong.title
                    self.nowPlayingArtist.text = nowPlayingSong.artist
                }
            }
        }
    }
    
    
    
    // 画面のどこかしらがシングルタップされたら
    @objc func handleSingleTapeed(_ gesture: UITapGestureRecognizer) -> Void {
        // 注意書きを表示してフェードアウトする
        self.animateFadeOut(view: self.noteView, delay: 1.0)
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
        self.animateFadeOut(view: self.noteView, delay: 1.0)
    }
    
    //NowPlayingの内容が変わったら更新して再表示
    @objc func handleNowPlayingItemDidChange(){
        if(DefaultsController.shared.isNowPlayingDisplayEnabled){
            self.noteView.layer.removeAllAnimations()
            updateNowPlaying()
            self.animateFadeOut(view: self.noteView, delay: 5.0)
        }
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
