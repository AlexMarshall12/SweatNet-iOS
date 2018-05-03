//
//  HomeViewController.swift
//  SweatNet
//
//  Created by Alex on 3/12/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import Kingfisher

private var reuseIdentifier = "TagCell"

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var tags = [Tag]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserService.tags(for: User.current) { (tags) in
            print(tags)
            self.tags = tags
            self.collectionView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var collectionView: UICollectionView!
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print(tags.count)
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = tags[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SNTagViewCell
        
        // Configure the cell
        //let imageURL = URL(string: tag.imageURL)
        cell.backgroundColor = UIColor.black
        cell.cellLabel.text = tag.title
        cell.cellLabel.textColor = UIColor.white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        print(indexPath.row)
        self.performSegue(withIdentifier: "viewTagPosts", sender: nil)
    }
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
    }
    
}
