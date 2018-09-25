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
    let showButton = UIBarButtonItem()
    let settingsButton = UIBarButtonItem()
    let titleSearchBar = UISearchBar()
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var popOverTransitioningDelegate = PopoverPresentationManager()


    override func viewDidLoad() {
        super.viewDidLoad()
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTags), name: NSNotification.Name(rawValue: "load"), object: nil)

        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController.searchBar
        }
        
        
        definesPresentationContext = true
        
        searchController.searchBar.delegate = self

        self.title = "tags"
        self.collectionView?.addGestureRecognizer(lpgr)
        self.collectionView.allowsMultipleSelection = true
        let items = self.tabBarController?.tabBar.items
        items![0].title = ""
        items![1].title = ""
        
        searchController.searchBar.delegate = self
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(UIImage(named: "Gear"), for: .normal)
        settingsButton.sizeToFit()
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show", style: .plain, target: self, action: #selector(showButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsButton)
        self.activityIndicator.startAnimating()
        UserService.tags(for: User.current) { (tags) in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.tags = tags.sorted(by: {
                $0.latestUpdate.compare($1.latestUpdate) == .orderedDescending
            })
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
    }
    
    @objc func reloadTags() {
        UserService.tags(for: User.current) { (tags) in
            self.tags = tags.sorted(by: {
                $0.latestUpdate.compare($1.latestUpdate) == .orderedDescending
            })
            self.filteredTags = self.tags
            for (_,tag) in tags.enumerated() {
                let tagColor = UIColor(red: tag.color[0],green: tag.color[1], blue: tag.color[2],alpha:1.0)
                tagColors.sharedInstance.dict[tag.title] = tagColor
            }
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectedTagTitles = []
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }

    @IBOutlet var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredTags.count
        }
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag: Tag
        if isFiltering() {
            tag = filteredTags[indexPath.item]
        } else {
            tag = tags[indexPath.item]
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SNTagViewCell
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
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2 + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = self.filteredTags[indexPath.item]
        for tag in self.filteredTags {
            print(tag.title, "filtered tag 2")
        }
        self.tagTitle = tag.title
        self.selectedTagTitles = [tag.title]
        
        self.performSegue(withIdentifier: "viewTagPosts", sender: nil)
    }
    @objc func showButtonPressed() {
        self.performSegue(withIdentifier: "viewTagPosts", sender: nil)
    }

    @objc func settingsButtonPressed() {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
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
            destination.selectedTagTitles = self.selectedTagTitles
        } else if segue.identifier == "showColorPicker" {
            if let controller = segue.destination as? TagEditViewController {
                controller.transitioningDelegate = popOverTransitioningDelegate
                controller.view.makeCorner(withRadius: 10.0)
                controller.modalPresentationStyle = .custom
            }
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredTags = self.tags.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        for tag in self.filteredTags {
            print(tag.title, "filtered tag")
        }
        self.collectionView?.reloadData()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    @objc func handleLongPress(_ gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state != UIGestureRecognizerState.began){
            return
        }
        let p = gestureRecognizer.location(in: self.collectionView)
        if let indexPath: IndexPath = self.collectionView?.indexPathForItem(at: p){
            self.performSegue(withIdentifier: "showColorPicker", sender: nil)

            //if let optionalCell = self.collectionView.cellForItem(at: indexPath) {
                //let cell = optionalCell as! SNTagViewCell
                
//                if cell.isSelected == false {
//                    selectedCells.sharedInstance.dict[indexPath] = true
//                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
////                    tagColors.sharedInstance.selectedTags.append(indexPath)
////                    cell.check.isHidden = false
////                    cell.checkInner.isHidden = false
////                    let tint = tagColors.sharedInstance.dict[cell.tagTitle.text!]
////                    cell.check.setImageColor(color: tint!)
//                    cell.isSelected = true
//                    cell.check.isHidden = false
//                } else {
////                    tagColors.sharedInstance.selectedTags.remove(at: Int(indexPath.item))
//                    selectedCells.sharedInstance.dict[indexPath] = false
//                    self.collectionView.deselectItem(at: indexPath, animated: true)
////                    cell.check.isHidden = true
////                    cell.checkInner.isHidden = true
//                    cell.isSelected = false
//                    cell.check.isHidden = true
//
//                }
                //resetShowButton()
            //}
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

    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
        print("unwound")
        self.selectedTagTitles.removeAll()
        print(self.selectedTagTitles,"unwound")
    }
    
}

extension HomeViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        // TODO
    }
}
