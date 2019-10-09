//
//  FirstViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/05.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    var player :MPMusicPlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        player = MPMusicPlayerController.applicationMusicPlayer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func jumpToLibraryButton(_ sender: Any) {
        let picker = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = true
        present(picker, animated: true, completion: nil)
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
