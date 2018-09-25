//
//  UIView+Corners.swift
//  SweatNet
//
//  Created by Alex on 9/24/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
extension UIView {
    func makeCorner(withRadius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.isOpaque = false
    }
}
