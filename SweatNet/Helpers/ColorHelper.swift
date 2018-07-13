//
//  ColorHelper.swift
//  SweatNet
//
//  Created by Alex on 6/29/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

public func newColor() {
    var h = CGFloat(0)
    if let seed = UserDefaults.standard.object(forKey: "color_seed") as? CGFloat {
        h = seed
    } else {
        h = CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    let golden_ratio_conjugate = CGFloat(0.618033988749895)
    h += golden_ratio_conjugate
    h = h.truncatingRemainder(dividingBy: 1.0)
    let seed = h
    UserDefaults.standard.set(seed,forKey:"color_seed")
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
    
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
