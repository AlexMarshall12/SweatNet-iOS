//
//  HomeViewController.swift
//  SweatNet
//
//  Created by Alex on 3/12/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import Kingfisher
import HSLuvSwift

private var reuseIdentifier = "TagCell"

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIGestureRecognizerDelegate {
    var tags = [Tag]()
    var filteredTags = [Tag]()
    var selectedTagTitles = [String]()
    var selectedTagIndexes = [Bool]()
    var tagTitle: String?
    var searchBarActive:Bool = false

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
        self.collectionView.allowsMultipleSelection = true
        UserService.tags(for: User.current) { (tags) in
            self.activityIndicator.stopAnimating()
//            self.tags = tags.sorted(by: {
//                $0.latestUpdate.compare($1.latestUpdate) == .orderedAscending
//            })
            self.tags = tags
            self.filteredTags = tags
            for (i,tag) in tags.enumerated() {
                let tagColor = UIColor(red: tag.color[0],green: tag.color[1], blue: tag.color[2],alpha:1.0)
                tagColors.sharedInstance.dict[tag.title] = tagColor
                let indexPath = IndexPath(row: i,section: 0)
                var selectedCellsDict = selectedCells.sharedInstance.dict
                if selectedCellsDict.index(forKey: indexPath) == nil {
                    selectedCellsDict[indexPath] = false
                } else if selectedCellsDict[indexPath] == true {
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
            self.resetShowButton()
            self.collectionView.reloadData()
        }
//        let background = UIView()
//        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        background.frame = collectionView.bounds
//        background.backgroundColor = UIColor.red
//        collectionView.addSubview(background)
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        self.searchBar.delegate = self
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.filteredTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = self.filteredTags[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SNTagViewCell
        
        // Configure the cell
        //let imageURL = URL(string: tag.imageURL)
        cell.backgroundColor = UIColor.black
        cell.tagTitle.text = " " + tag.title + " "
        if let selected = selectedCells.sharedInstance.dict[indexPath] {
            cell.isSelected = selected
        } else {
            cell.isSelected = false
        }
        cell.check.isHidden = !cell.isSelected
        cell.tagTitle.backgroundColor = tagColors.sharedInstance.dict[tag.title]
        cell.tagTitle.layer.cornerRadius = 5
        cell.tagTitle.layer.masksToBounds = true
        cell.customSelect = selectedCells.sharedInstance.dict[indexPath]
        cell.layer.cornerRadius = 5
        cell.imageView.layer.cornerRadius = 5
        let latestUpdateDate = tag.latestUpdate
        cell.latestUpdate.text = timeAgoSinceDate(latestUpdateDate)
        let thumbURL = URL(string: tag.latestThumbnailURL)
        cell.imageView.kf.setImage(with: thumbURL)
        //cell.latestUpdate.textColor = UIColor(red:0.40, green:0.80, blue:1.00, alpha:1.0)
        cell.tagTitle.textColor = UIColor.white
        cell.latestUpdate.font = UIFont(name: "HelveticaNeue", size:12.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  50
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = self.filteredTags[indexPath.item]
        self.tagTitle = tag.title
        self.selectedTagTitles = [tag.title]
        self.performSegue(withIdentifier: "viewTagPosts", sender: nil)
        self.collectionView.deselectItem(at: indexPath, animated: false)
    }
    @IBAction func showButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "viewTagPosts", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewTagPosts" {
            let destination = segue.destination as! TagViewController
            let selectedItemIndexes = self.collectionView.indexPathsForSelectedItems
            var selectedTagTitles: [String] = []
            for index in selectedItemIndexes! {
                print(index.row,"selectedItemIndexes")
                let tagTitle = tags[index.row].title
                selectedTagTitles.append(tagTitle)
            }
            destination.selectedTagTitles = selectedTagTitles
        }
    }
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String){
        if searchText.count > 0 {
            // search and reload data source
            self.searchBarActive = true
            self.filteredTags = self.tags.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            self.collectionView?.reloadData()
        } else {
            // if text lenght == 0
            // we will consider the searchbar is not active
            self.searchBarActive = false
            self.collectionView?.reloadData()
        }
    }
    @objc func handleLongPress(_ gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state != UIGestureRecognizerState.began){
            return
        }
        let p = gestureRecognizer.location(in: self.collectionView)
        if let indexPath: IndexPath = self.collectionView?.indexPathForItem(at: p){
            if let optionalCell = self.collectionView.cellForItem(at: indexPath) {
                let cell = optionalCell as! SNTagViewCell
                if cell.isSelected == false {
                    selectedCells.sharedInstance.dict[indexPath] = true
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
//                    tagColors.sharedInstance.selectedTags.append(indexPath)
//                    cell.check.isHidden = false
//                    cell.checkInner.isHidden = false
//                    let tint = tagColors.sharedInstance.dict[cell.tagTitle.text!]
//                    cell.check.setImageColor(color: tint!)
                    cell.isSelected = true
                    cell.check.isHidden = false
                } else {
//                    tagColors.sharedInstance.selectedTags.remove(at: Int(indexPath.item))
                    selectedCells.sharedInstance.dict[indexPath] = false
                    self.collectionView.deselectItem(at: indexPath, animated: true)
//                    cell.check.isHidden = true
//                    cell.checkInner.isHidden = true
                    cell.isSelected = false
                    cell.check.isHidden = true
                }
                resetShowButton()
            }
        }
    }
    
    func resetShowButton(){
        if (self.collectionView.indexPathsForSelectedItems?.count)! > 0 {
            showButton.isEnabled = true
        } else {
            print("selectedCell",(self.collectionView.indexPathsForSelectedItems?.count)!)
            showButton.isEnabled = false
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchBarActive = false
        self.searchBar.endEditing(true)
    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
//        self.searchBarActive = true
//
//    }
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
        print("unwound")
        self.selectedTagTitles.removeAll()
        print(self.selectedTagTitles,"unwound")
    }
    
}
