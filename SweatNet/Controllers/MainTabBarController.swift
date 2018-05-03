//
//  MainTabBarController.swift
//  SweatNet
//
//  Created by Alex on 3/13/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    let photoHelper = SNPhotoHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //photoHelper.completionHandler = { media in
          //  PostService.create(for: media)
        //}
        // 1
        delegate = self
        // 2
        tabBar.unselectedItemTintColor = .black
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 1 {
            // present photo taking action sheet
            photoHelper.presentActionSheet(from: self)
            return false
        } else {
            return true
        }
    }
}
