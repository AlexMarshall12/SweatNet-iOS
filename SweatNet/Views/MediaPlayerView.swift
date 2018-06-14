//
//  MediaPlayerView.swift
//  SweatNet
//
//  Created by Alex on 5/14/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit
import AVFoundation

class MediaPlayerView: UIView {
    
    var mediaURL: URL? {
        didSet {
            determineMediaType()
        }
    }
    let videoExtensions = ["mov"]
    var asset: AVURLAsset?
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    var player: AVPlayer?{
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    
    private var playerItem: AVPlayerItem? = nil

    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //determineMediaType()
    }
    
    func determineMediaType() {
        let url = self.mediaURL
        let pathExtention = url?.pathExtension
        if videoExtensions.contains(pathExtention!) {
            print("Movie URL: \(String(describing: url))")
            setupVideo(url: url!)
        } else {
            print("Image URL: \(String(describing: url))")
            setupImage(url: url!)
        }
    }
    
    func setupVideo(url: URL) {
        //self.layer.addSublayer(playerLayer)
        //asset = AVURLAsset(url: url, options: nil)
        let playButton = UIImage(named: "Play Triangle")
        let playButtonView = UIImageView(image: playButton!)
        let singleTap = UITapGestureRecognizer(target: self,  action: #selector(tapDetected))
        playButtonView.addGestureRecognizer(singleTap)
        playButtonView.center = self.center
        playButtonView.frame.size.width  = self.frame.size.width/5
        playButtonView.frame.size.height = self.frame.size.height/5
        playButtonView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        playButtonView.isUserInteractionEnabled = true
        self.addSubview(playButtonView)
    }
    
    @objc func tapDetected() {
        print("tap!")
        let player = AVPlayer(url: self.mediaURL!)
        let controller = AVPlayerViewController()
        controller.player = player
        self.window?.rootViewController?.present(controller, animated: true) {
            player.play()
        }
    }
    
    func setupImage(url: URL) {
        let imageView = UIImageView()
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(imageView)
        imageView.kf.setImage(with: url)
    }

}
