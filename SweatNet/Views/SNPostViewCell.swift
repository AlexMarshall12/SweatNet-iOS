//
//  SNPostViewCell.swift
//  SweatNet
//
//  Created by Alex on 5/3/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
//
//struct cellPostAttributes {
//    let ID: String?
//    let notes: String?
//    let postDate: Date?
//    let tags: [String:UIColor]?
//}

class SNPostViewCell: UICollectionViewCell, UITextViewDelegate {
    var isVideo: Bool?
    var postId: String?
    var tagColorsDict: [String:UIColor]? {
        didSet {
            for (tag,color) in tagColorsDict! {
                let token = KSToken(title: tag)
                token.tokenBackgroundColor = color
                tagsView.addToken(token)
            }
        }
    }
    let videoExtensions = ["mov"]
    var thisPost:cellPostAttributes?
    
    @IBOutlet weak var tagsView: KSTokenView!
    var delegate: SNPostViewCellDelegate?

    @IBOutlet weak var notesToBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var notes: UITextView!
    @IBAction func playButtonPressed(_ sender: Any) {
        self.delegate?.playButtonPressed(playbackURL: mediaURL)
    }
    @IBAction func editButtonPressed(_ sender: Any) {
        self.delegate?.editButtonPressed(postID: thisPost?.ID, notes: thisPost?.notes, postDate: thisPost?.postDate, tags: thisPost?.tags)
    }
    
    var mediaURL: URL? {
        didSet {
            if self.isVideo == true {
                playButton.isHidden = false
            } else if self.isVideo == false {
                playButton.isHidden = true
            } else {
                return
            }
        }
    }
    
    var thumbnailURL: URL? {
        didSet {
            print("did set thumbnail")
            thumbnail.kf.setImage(with: self.thumbnailURL)
        }
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    override func prepareForReuse() {
        tagsView.deleteAllTokens()
    }
}
protocol SNPostViewCellDelegate {
    func playButtonPressed(playbackURL: URL?)
    func editButtonPressed(postID: String?, notes: String?, postDate: Date?,tags: [String]?)
}
