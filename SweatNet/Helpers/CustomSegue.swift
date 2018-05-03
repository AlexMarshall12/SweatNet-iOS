//
//  CustomSegue.swift
//  SweatNet
//
//  Created by Alex on 4/6/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    override func perform() {
        
        let src = self.source
        let dst = self.destination
        src.navigationController?.pushViewController(dst, animated: true)
    }
}
