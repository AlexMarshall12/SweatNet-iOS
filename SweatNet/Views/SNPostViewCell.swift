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

class SNPostViewCell: UICollectionViewCell, UITextViewDelegate {
    var isVideo: Bool?
    let videoExtensions = ["mov"]

    var delegate: SNPostViewCellDelegate?
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.myCustomCellDidUpdate(cell: self, newContent: textView.text)
    }

    @IBOutlet weak var notesToBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var notes: UITextView!
    @IBAction func playButtonPressed(_ sender: Any) {
        self.delegate?.playButtonPressed(playbackURL: mediaURL)
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

}
protocol SNPostViewCellDelegate {
    func myCustomCellDidUpdate(cell: SNPostViewCell, newContent: String)
    func playButtonPressed(playbackURL: URL?)
}
