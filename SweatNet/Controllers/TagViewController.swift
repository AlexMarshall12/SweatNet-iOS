//
//  TagViewController.swift
//  SweatNet
//
//  Created by Alex on 5/2/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import AVKit
import Foundation
import AVFoundation

private var reuseIdentifier = "PostCell"
private var timelineMonthCellReuseIdentifier = "timelineMonthCell"

class TagViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, PostCollectionViewCellDelegate {
    func editButtonPressed(postID: String?, notes: String?, postDate: Date?, tags: [String]?) {
        editPostAttributes = EditPostAttributes(postId: postID, postDate: postDate, notes: notes, tags: tags)
        self.performSegue(withIdentifier: "editContent", sender: nil)
    }
    
    var editPostAttributes: EditPostAttributes?

    var posts: [Post] = []
    var months: Int?
    var postIds: [String] = []
    var firstPostDate: Date?
    var dayTicks = [Date:UIView]()
    //var playbackURL: URL?
    var tagTitle: String!
    var selectedTagTitles: [String]!
    var currentPostMonth: Int = 0
    var currentPostDate: Date?
    var currentPostIndex: Int = 0
    var currentPostId: String?
    var postStuff: ([Post],[String])?
    var tags = [Tag]()
    var onceOnly = false
//    var backInRange: Bool = true
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()

    //private var dataSources: [IndexPath : dayCellDelegates] = [:]
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timeline: UICollectionView!
//    @IBOutlet weak var leftArrow: UIImageView!
//    @IBOutlet weak var rightArrow: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeline.register(UINib(nibName: "TimelineMonthViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelineMonthViewCell")
        self.collectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostCollectionViewCell")
        pageControl.hidesForSinglePage = true
        self.navigationItem.largeTitleDisplayMode = .never
       
        UserService.posts(for: User.current,tagString: self.selectedTagTitles.first!) { (postStuff) in
            print(self.selectedTagTitles,"tagtitle")
            self.posts = postStuff.0
            self.postIds = postStuff.1
            self.timeline.dataSource = self
            self.collectionView.dataSource = self
            self.timeline.delegate = self
            self.collectionView.delegate = self
            self.firstPostDate = self.posts.first?.timeStamp
            self.currentPostDate = self.posts.last?.timeStamp
        }
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.timeline.register(UINib(nibName: "TimelineMonthViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelineMonthViewCell")
//        self.collectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostCollectionViewCell")
//        pageControl.hidesForSinglePage = true
//        self.collectionView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.94, alpha:1.0)
//
//        let myGroup = DispatchGroup()
//        var allPosts: [Post] = []
//        var allIds: [String] = []
//        self.navigationItem.largeTitleDisplayMode = .never
//        self.collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
//        for tag in self.selectedTagTitles {
//            print(tag,"my tag")
//            myGroup.enter()
//            UserService.posts(for: User.current,tagString: tag) { (postStuff) in
//                allPosts += postStuff.0
//                allIds += postStuff.1
//                self.postStuff = postStuff
////                for i in 0...postStuff.1.count {
////                    print(i,postStuff.0[i],"stuff",postStuff.1[i])
////                    allPosts[postStuff.1[i]] = postStuff.0[i]
////                }
//                myGroup.leave()
//            }
//        }
//
//        myGroup.notify(queue: .main) {
//            let combined = zip(allPosts,allIds).sorted(by: {
//                $0.0.timeStamp.compare($1.0.timeStamp) == .orderedAscending
//            })
//            self.posts = combined.map {tuple in tuple.0}
//            self.postIds = combined.map {tuple in tuple.1}
//
////            self.posts = allPosts.sorted(by: {
////                $0[.timeStamp].compare($1.timeStamp) == .orderedAscending
////            })
//            self.currentPostDate = self.posts.first?.timeStamp
//            self.timeline.dataSource = self
//            self.collectionView.dataSource = self
//            self.timeline.delegate = self
//            self.collectionView.delegate = self
//            self.updateTitleWithDate(date: self.posts[0].timeStamp)
//            let indexToScrollTo = IndexPath(row: self.posts.count - 1, section: 0)
//            self.collectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
//            let firstPost = self.posts.first?.timeStamp
//            let firstOfFirstMonth = firstPost?.startOfMonth()
//            let diff = self.posts.last?.timeStamp.months(from: firstOfFirstMonth!)
//            //self.currentPostMonth = diff
//            let monthCellIndexPath = IndexPath(row: diff!, section: 0)
//            self.timeline.scrollToItem(at: monthCellIndexPath, at: .centeredHorizontally, animated: false)
//
//            let months = self.posts.first?.timeStamp.startOfMonth().months(from: (self.posts.last?.timeStamp)!)
//            print("cells are",self.timeline.visibleCells)
//            if let optionalCell = self.timeline.cellForItem(at: IndexPath(row: months!, section: 0)) {
//                let cell = optionalCell as! TimelineMonthViewCell
//                let day = Calendar.current.component(.day, from: self.currentPostDate!)
//                cell.drawArrow(day: day)
//            } else {
//                print("cell out of range")
//            }
//        }
////        let background = UIView()
////        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        background.frame = timeline.bounds
////        background.backgroundColor = UIColor.red
////        timeline.addSubview(background)
//        // Do any additional setup after loading the view.
//        hideKeyboardWhenTappedAround()
//    }
//
//    
//    var onceOnlyCollectionView = false
//    var onceOnlyTimeline = false
//    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if collectionView == self.collectionView {
//            if !onceOnlyCollectionView {
//                let indexToScrollTo = IndexPath(row: self.posts.count - 1, section: 0)
//                collectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
//                onceOnlyCollectionView = true
//            }
//        } else if collectionView == self.timeline {
//            if !onceOnlyTimeline {
////                let firstPost = posts.first?.timeStamp
////                let firstOfFirstMonth = firstPost?.startOfMonth()
////                let diff = posts.last?.timeStamp.months(from: firstOfFirstMonth!)
////                //self.currentPostMonth = diff
////                let monthCellIndexPath = IndexPath(row: diff!, section: 0)
////                timeline.scrollToItem(at: monthCellIndexPath, at: .centeredHorizontally, animated: false)
//                let months = self.posts.first?.timeStamp.startOfMonth().months(from: (self.posts.last?.timeStamp)!)
//                print("cells are",self.timeline.visibleCells)
//                if let optionalCell = timeline.cellForItem(at: IndexPath(row: months!, section: 0)) {
//                    let cell = optionalCell as! TimelineMonthViewCell
//                    let day = Calendar.current.component(.day, from: self.currentPostDate!)
//                    cell.drawArrow(day: day)
//                } else {
//                    print("cell out of range")
//                }
//                onceOnlyTimeline = true
//            }
//        }
//    }
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let indexToScrollTo = IndexPath(row: self.posts.count - 1, section: 0)
        //self.collectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
        let firstPostDate = self.posts.first?.timeStamp
        print (firstPostDate?.startOfMonth(),self.posts.last?.timeStamp,"timestamps")
        let diff = self.posts.last?.timeStamp.months(from: (firstPostDate?.startOfMonth())!)
        //self.currentPostMonth = diff
        let monthCellIndexPath = IndexPath(row: diff!, section: 0)
        self.timeline.scrollToItem(at: monthCellIndexPath, at: .centeredHorizontally, animated: false)
//        let months = self.posts.last?.timeStamp.months(from: (self.posts.first?.timeStamp.startOfMonth())!)
//        print("cells are",self.timeline.indexPathsForVisibleItems)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        //let attributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
        //self.navigationController?.navigationBar.titleTextAttributes = attributes
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            self.pageControl.numberOfPages = posts.count
            return posts.count
        } else if collectionView == self.timeline {
            let first = posts.first?.timeStamp
            let last = posts.last?.timeStamp
            let months = last?.months(from: (first?.startOfMonth())!) ?? 0
            print("no of months",months)

            if let diff = last?.months(from: first!), diff <= 5 {
                return months + 5-diff
            } else {
                return months + 1
            }
        } else {
            preconditionFailure("Unknown collection view!")
        }
    }

    func playButtonPressed(playbackURL: URL?) {
        //self.playbackURL = playbackURL
        print("making controller")
        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: playbackURL!)
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    func performedTagSearchWithString(cell: SNPostViewCell, string: String, completion: ((_ results: Array<AnyObject>) -> Void)?){

        if (string.isEmpty){
            completion!(tags as Array<AnyObject>)
            return
        }
        let filteredTags = self.tags.filter { $0.title.localizedCaseInsensitiveContains(string) }
        completion!(filteredTags as Array<AnyObject>)
    }
    func displayTagTitleForObject(cell: SNPostViewCell, object: Tag) -> String {
        return object.title
    }
    
    func dates(_ dates: [Post], withinMonth month: Int, withinYear year: Int) -> [Post] {
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.month,.year]
        let filtered = posts.filter { (post) -> Bool in
            let monthAndYear = calendar.dateComponents(components, from: post.timeStamp)
            return (monthAndYear.month == month && monthAndYear.year == year)
        }
        return filtered
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let post = posts[indexPath.row]
            print(post,"mypost")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
            cell.thisPost = cellPostAttributes(ID: postIds[indexPath.item], notes: post.notes, isVideo: post.isVideo, postDate: post.timeStamp, mediaURL: URL(string: post.mediaURL), thumbnailURL: URL(string: post.thumbnailURL), tags: Array(post.tags.keys))
            cell.delegate = self
            return cell
        } else if collectionView == self.timeline {
            let index = indexPath.row
            print(index,"index")
            let calendar = Calendar.current
            let firstPost = self.posts.first?.timeStamp
            
            let monthDate = calendar.date(byAdding: .month, value: index, to: firstPost!)
            let monthInt = calendar.component(.month, from: monthDate!)
            let yearInt = calendar.component(.year, from: monthDate!)
            let monthPosts = dates(self.posts, withinMonth: monthInt, withinYear: yearInt)
            let days = calendar.range(of: .day, in: .month, for: monthDate!)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineMonthViewCell", for: indexPath) as! TimelineMonthViewCell
            cell.setDays(num: (days?.count)!)
            cell.currentQueryTags = self.selectedTagTitles
            cell.colorViews(monthPosts: monthPosts)
            cell.year = yearInt
            cell.month = monthInt
            cell.monthLabel.text = dateFormatter.string(from: monthDate!)
            if !self.onceOnly {
                let months = self.posts.last?.timeStamp.months(from: (self.posts.first?.timeStamp.startOfMonth())!)
                print(index,months,"cell")
                if index == months! {
                    print(index,months,"Theyre the same cell")
                    cell.drawArrow(day: Calendar.current.component(.day, from: (self.currentPostDate)!))
                    self.onceOnly = true
                }
            }
            return cell
        } else {
            preconditionFailure("Unknown collection view!")
        }
    }
    
    func drawFirstRedArrow() {
        if let optionalCell = self.timeline.cellForItem(at: IndexPath(row: 0, section: 0)) {
            let cell = optionalCell as! TimelineMonthViewCell
            let day = Calendar.current.component(.day, from: self.currentPostDate!)
            cell.drawArrow(day: day)
        } else {
            print("first cell not in range")
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.timeline {
            print("Did finished")
        }
        if scrollView == self.collectionView {
            //clear current arrow
            let previousCell = self.currentPostDate?.months(from: (self.firstPostDate?.startOfMonth())!)
            let previousCellIndexPath = IndexPath(row: previousCell!, section: 0)
            
            //get current post for timestamp
            currentPostIndex = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
            let post = posts[currentPostIndex]
            self.currentPostId = post.id
            self.currentPostDate = post.timeStamp
            self.pageControl.currentPage = currentPostIndex

            //only clear cell arrow if it is already in an existing cell. Otherwise it will get cleared in prepareForReuse
            if let optionalCell = self.timeline.cellForItem(at: previousCellIndexPath) {
                let cell = optionalCell as! TimelineMonthViewCell
                cell.clearArrow()
                print("cleared", previousCellIndexPath.row)
            } else {
                print("cell not loaded", previousCellIndexPath.row)
            }
            
            let firstPost = posts.first?.timeStamp
            let firstOfFirstMonth = firstPost?.startOfMonth()
            let diff = post.timeStamp.months(from: firstOfFirstMonth!)
            //self.currentPostMonth = diff
            let monthCellIndexPath = IndexPath(row: diff, section: 0)
            
            updateTitleWithDate(date: post.timeStamp)
            
            if self.timeline.indexPathsForVisibleItems.contains(monthCellIndexPath) {
                
                //try to draw the arrow
                let index = self.currentPostDate?.months(from: (self.firstPostDate?.startOfMonth())!)
                if let optionalCell = self.timeline.cellForItem(at: IndexPath(row: index!, section: 0)) {
                    let cell = optionalCell as! TimelineMonthViewCell
                    let day = Calendar.current.component(.day, from: self.currentPostDate!)
                    cell.drawArrow(day: day)
                    print("drew arrow, cell in range")
                } else {
                    print("blk")
                }
            } else {
                self.timeline.scrollToItem(at: monthCellIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == self.timeline {
//            let months = self.posts.first?.timeStamp.startOfMonth().months(from: (self.posts.last?.timeStamp)!)
//            let monthCellIndexPath = IndexPath(row: months!, section: 0)
//            print("cells are",self.timeline.visibleCells)
//            if let optionalCell = timelinecellForItem(at: monthCellIndexPath) {
//                let cell = optionalCell as! TimelineMonthViewCell
//                let day = Calendar.current.component(.day, from: self.currentPostDate!)
//                cell.drawArrow(day: day)
//            } else {
//                print("cell out of range")
//            }
//        }
//    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == timeline {
            print("Did finish")
            let index = self.currentPostDate?.months(from: (self.firstPostDate?.startOfMonth())!)
            if let optionalCell = self.timeline.cellForItem(at: IndexPath(row: index!, section: 0)) {
                let cell = optionalCell as! TimelineMonthViewCell
                let day = Calendar.current.component(.day, from: self.currentPostDate!)
                cell.drawArrow(day: day)
            } else {
                print("cell out of range")
            }
        }
    }
    
    func updateTitleWithDate(date:Date){
        let dateFormatter = DateFormatter()
        if Calendar.current.component(.year, from: date) == Calendar.current.component(.year, from: Date()){
            dateFormatter.dateFormat = "MMM dd"
        } else {
            dateFormatter.dateFormat = "MMM dd, yyyy"
        }
        self.title = dateFormatter.string(from: date)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("finding height2")
        if collectionView == self.collectionView {
            return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        } else {
            return CGSize(width: collectionView.bounds.size.width/5, height: collectionView.bounds.size.height)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        if let controller = segue.destination as? AVPlayerViewController {
//            controller.player = AVPlayer(url: self.playbackURL!)
//            tabBarController?.tabBar.isHidden = true
//            //self.navigationController?.navigationBar.isHidden = true
//            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//            //self.navigationController?.navigationBar.shadowImage = UIImage()
//            //self.navigationController?.navigationBar.isTranslucent = true
//            //self.navigationController!.view.backgroundColor = UIColor.clear
//            //self.navigationController?.navigationBar.backgroundColor = UIColor.clear
////            controller.navigationController?.navigationBar.isTranslucent = false
////            controller.navigationController?.view.backgroundColor = .clear
//            controller.player?.play()
//        } else if let controller = segue.destination as? EditPostContentViewController {
        if let controller = segue.destination as? EditPostContentViewController {
            controller.postAttrs = editPostAttributes
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
    }
    @IBAction func unwindToPosts(sender: UIStoryboardSegue) {
        collectionView.reloadItems(at: [IndexPath(row: currentPostIndex, section: 0)])
    }

}

extension TagViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

}

