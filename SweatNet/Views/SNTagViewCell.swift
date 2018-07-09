//
//  SNCollectionViewCell.swift
//  SweatNet
//
//  Created by Alex on 4/23/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

class SNTagViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var check: UIImageView!
    
    @IBOutlet weak var tagTitle: UILabel!
    @IBOutlet weak var latestUpdate: UILabel!
    
    var customSelect: Bool?
//        didSet {
////            self.checkInner.isHidden = false
////            self.layer.borderWidth = 2.0
//            self.layer.borderColor = isSelected ? tagColors.sharedInstance.dict[tagTitle.text!]?.cgColor : UIColor.clear.cgColor
//        }
//    }
}
