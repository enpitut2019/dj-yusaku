//
//  FirstViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/05.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import MediaPlayer

class FirstViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    var player = MPMusicPlayerController.applicationMusicPlayer
    let picker = MPMediaPickerController()
    let permissionStatus = MPMediaLibrary.authorizationStatus()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayPermissionAlert(){
        let alert = UIAlertController(
            title: "アクセス許可の要求",
            message: "設定->DJ-YUSAKUを開いて、「メディアとAppleMusic」へのアクセス許可をしてください",
            preferredStyle: .alert
        )
        alert.popoverPresentationController?.sourceView = self.view
        
        alert.addAction(UIAlertAction(title: "許可しない", style: .default, handler: nil))
        
        
        let openSettingsAction = UIAlertAction(title: "「設定」を開く", style: .default){ _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(openSettingsAction)
        
        self.presentedViewController?.dismiss(animated: false, completion: nil)
        present(alert, animated: true, completion: nil)
        
    }

    @IBAction func jumpToLibraryButton(_ sender: Any) {
        if(permissionStatus == .denied || permissionStatus == .restricted){
            displayPermissionAlert()
        }else{
            picker.delegate = self
            picker.allowsPickingMultipleItems = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        player.setQueue(with: mediaItemCollection)
        player.play()
        dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func playButton(_ sender: Any) {
//        print("play")
        player.play()
    }
    
    @IBAction func pauseButton(_ sender: Any) {
//        print("pause")
        player.pause()
    }
    
    @IBAction func stopButton(_ sender: Any) {
//        print("stop")
        player.stop()
    }
}
