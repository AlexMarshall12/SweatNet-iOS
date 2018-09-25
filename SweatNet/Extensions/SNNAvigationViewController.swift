//
//  SNNAvigationViewController.swift
//  SweatNet
//
//  Created by Alex on 7/16/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

class SNNAvigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    


}
