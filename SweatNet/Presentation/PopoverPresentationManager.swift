//
//  PopoverPresentationManager.swift
//  SweatNet
//
//  Created by Alex on 9/24/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
class PopoverPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = PopoverPresentationController(presentedViewController: presented,
                                                                   presenting: presenting)
        return presentationController
    }
}

