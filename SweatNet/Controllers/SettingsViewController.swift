//
//  SettingsViewController.swift
//  SweatNet
//
//  Created by Alex on 7/10/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var storageAmount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bytes = UserDefaults.standard.integer(forKey: "total_storage")
        storageAmount.text = format(bytes:Double(bytes))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
