//
//  SlideInPresentationManager.swift
//  SweatNet
//
//  Created by Alex on 6/28/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//
import UIKit
class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                                   presenting: presenting)
        return presentationController
    }
}

