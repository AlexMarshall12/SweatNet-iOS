//
//  PostCollectionViewCell.swift
//  SweatNet
//
//  Created by Alex on 7/11/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

struct cellPostAttributes {
    let ID: String?
    let notes: String?
    let isVideo: Bool?
    let postDate: Date?
    let mediaURL: URL?
    let thumbnailURL: URL?
    let tags: [String]?
}

class PostCollectionViewCell: UICollectionViewCell {

    var delegate: PostCollectionViewCellDelegate?

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var tagsView: KSTokenView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tagsAndEditContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        //tagsView.removesTokensOnEndEditing = false
        //tagsView.promptText = ""
        tagsView.isUserInteractionEnabled = false
        notes.isUserInteractionEnabled = false
        // Initialization code
        tagsAndEditContainer.round(corners: [.topLeft,.topRight], radius: 10)
        timestampLabel.layer.cornerRadius = 10
        //timestampLabel.round(corners: [.topLeft,.bottomLeft], radius: 10)
        timestampLabel.clipsToBounds = true
    }
    
    var thisPost:cellPostAttributes? {
        didSet {
            for tag in (thisPost?.tags)! {
                let token = KSToken(title: tag)
                let tokenColor = tagColors.sharedInstance.dict[tag]
                token.tokenBackgroundColor = tokenColor!
                tagsView.addToken(token)
            }
            if thisPost?.isVideo == true {
                playButton.isHidden = false
            } else {
                playButton.isHidden = true
            }
            thumbnail.kf.setImage(with: thisPost?.thumbnailURL)
            timestampLabel.sizeToFit()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            timestampLabel.text = formatter.string(from: (thisPost?.postDate)!)
//            timestampLabel.text = " " + timestampLabel.text! + " " 
            tagsView.removesTokensOnEndEditing = false
            tagsView.promptText = ""
            notes.text = thisPost?.notes
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        self.delegate?.playButtonPressed(playbackURL: thisPost?.mediaURL)
    }
    @IBAction func editButtonPressed(_ sender: Any) {
        print("edit button pressed")
        self.delegate?.editButtonPressed(postID: thisPost?.ID, notes: thisPost?.notes, postDate: thisPost?.postDate, tags: thisPost?.tags)
    }
    
    override func prepareForReuse() {
        tagsView.deleteAllTokens()
    }
    
}

protocol PostCollectionViewCellDelegate {
    func playButtonPressed(playbackURL: URL?)
    func editButtonPressed(postID: String?, notes: String?, postDate: Date?,tags: [String]?)
}
