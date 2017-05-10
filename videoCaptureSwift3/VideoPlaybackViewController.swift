//
//  VideoPlaybackViewController.swift
//  videoCaptureSwift3
//
//  Created by Sanket on 08/05/17.
//

import Foundation
import UIKit
import AVFoundation

class VideoPlaybackViewController : UIViewController {
        
        let avPlayer = AVPlayer()
        var avPlayerLayer: AVPlayerLayer!
        
        var videoURL: URL!
        var beforeCompression:String!
        var afterCompression:String!
        //connect this to your uiview in storyboard
        @IBOutlet weak var videoView: UIView!
        @IBOutlet weak var btnReplay: UIButton!
        
        @IBOutlet weak var lblBefore: UILabel!
        
        @IBOutlet weak var lblAfter: UILabel!
         @IBOutlet weak var btnBack: UIButton!
        
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.frame = view.bounds
                avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoView.layer.insertSublayer(avPlayerLayer, at: 0)
                
                view.layoutIfNeeded()
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(VideoPlaybackViewController.videoPlayDidFinish(_:)),
                                                       name: .AVPlayerItemDidPlayToEndTime,
                                                       object: avPlayer.currentItem)
                
                
                
                btnReplay.isHidden = true;
                btnBack.isHidden = true;
                
                playVideo("" as AnyObject);
                
        }
        
        override func viewDidAppear(_ animated: Bool) {
                lblBefore.text = beforeCompression;
                lblAfter.text = afterCompression;
        }
        
        func videoPlayDidFinish(_ notification: NSNotification) {
                
                btnReplay.isHidden = false;
                btnBack.isHidden = false;
        }
        
        @IBAction func playVideo(_ sender: AnyObject) {
                
                let playerItem = AVPlayerItem(url: videoURL as URL)
                avPlayer.replaceCurrentItem(with: playerItem)
                avPlayer.play()
                
                btnReplay.isHidden = true;
                btnBack.isHidden = true;
        }
        @IBAction func backPressed(_ sender: AnyObject) {
                
                dismiss(animated: true, completion: nil)
        }
        
        deinit {
                NotificationCenter.default.removeObserver(self)
        }

}
