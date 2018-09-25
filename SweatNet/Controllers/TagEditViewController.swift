//
//  TagEditViewController.swift
//  SweatNet
//
//  Created by Alex on 9/24/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import ChromaColorPicker
class TagEditViewController: UIViewController, ChromaColorPickerDelegate{
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        print("chosen color", color)
    }
    

    @IBOutlet weak var ColorPicker: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let neatColorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        neatColorPicker.delegate = self
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
//        neatColorPicker.hexLabel.textColor = UIColor.white
        view.addSubview(neatColorPicker)
        
        neatColorPicker.layout()


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
