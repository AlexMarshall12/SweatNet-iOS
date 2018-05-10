//
//  TagViewController.swift
//  SweatNet
//
//  Created by Alex on 5/2/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

private var reuseIdentifier = "PostCell"

class TagViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource {
    var posts = [Post]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded tag view controller")
        UserService.posts(for: User.current) { (posts) in
            self.posts = posts
            self.collectionView.reloadData()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let _ = posts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SNPostViewCell
        //let thumbURL = URL(string: )
        //cell.imageView.kf.setImage(with: thumbURL)
        cell.backgroundColor = UIColor.black
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
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
