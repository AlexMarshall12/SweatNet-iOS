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
    var tagTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        UserService.tags(for: User.current) { (tags) in
            self.tags = tags
            self.collectionView.reloadData()
        }
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
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = tags[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SNTagViewCell
        
        // Configure the cell
        //let imageURL = URL(string: tag.imageURL)
        cell.backgroundColor = UIColor.black
        cell.tagTitle.text = tag.title
        let latestUpdateDate = tag.latestUpdate
        cell.latestUpdate.text = timeAgoSinceDate(latestUpdateDate)
        let thumbURL = URL(string: tag.latestThumbnailURL)
        cell.imageView.kf.setImage(with: thumbURL)
        cell.latestUpdate.textColor = UIColor(red:0.40, green:0.80, blue:1.00, alpha:1.0)
        cell.tagTitle.textColor = UIColor.white
        cell.latestUpdate.font = UIFont(name: "HelveticaNeue", size:11.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = tags[indexPath.item]
        self.tagTitle = tag.title
        self.performSegue(withIdentifier: "viewTagPosts", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewTagPosts" {
            let destination = segue.destination as! TagViewController
            destination.tagTitle = self.tagTitle
        }
    }
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
    }
    
}
