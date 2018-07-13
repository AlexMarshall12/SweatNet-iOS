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
    }
    
    var editPostAttributes: EditPostAttributes?

    var posts = [Post]()
    var postIds = [String]()
    var dayTicks = [Date:UIView]()
    var playbackURL: URL?
    var tagTitle: String!
    var selectedTagTitles: [String]!
    var currentPostMonth: Int = 0
    var currentPostDate: Date?
    var currentPostId: String?
    var postStuff: ([Post],[String])?
    var tags = [Tag]()
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
        self.collectionView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.94, alpha:1.0)

        let myGroup = DispatchGroup()
        var allPosts: [Post] = []
        var allIds: [String] = []
        for tag in self.selectedTagTitles {
            print(tag,"my tag")
            myGroup.enter()
            UserService.posts(for: User.current,tagString: tag) { (postStuff) in
                allPosts += postStuff.0
                allIds += postStuff.1
                self.postStuff = postStuff
//                for i in 0...postStuff.1.count {
//                    print(i,postStuff.0[i],"stuff",postStuff.1[i])
//                    allPosts[postStuff.1[i]] = postStuff.0[i]
//                }
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            let combined = zip(allPosts,allIds).sorted(by: {
                $0.0.timeStamp.compare($1.0.timeStamp) == .orderedAscending
            })
            self.posts = combined.map {tuple in tuple.0}
            self.postIds = combined.map {tuple in tuple.1}
            
//            self.posts = allPosts.sorted(by: {
//                $0[.timeStamp].compare($1.timeStamp) == .orderedAscending
//            })
            self.currentPostDate = self.posts.first?.timeStamp
            self.timeline.dataSource = self
            self.collectionView.dataSource = self
            self.timeline.delegate = self
            self.collectionView.delegate = self
        }
//        let background = UIView()
//        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        background.frame = timeline.bounds
//        background.backgroundColor = UIColor.red
//        timeline.addSubview(background)
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        print(self.selectedTagTitles,"tagTitles")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
    func textViewDidEndEditing(_ textView: UITextView) {
        print("exampleTextView: END EDIT")
    }
//    func myCustomCellDidUpdate(cell: SNPostViewCell, newContent: String) { // do stuff on your view controller with the cell or the new content
//        let index = self.collectionView.indexPath(for: cell)?.item
//        let postId = postIds[index!]
//        PostService.updatePostNotes(id: postId, notes: newContent)
//    }
    func playButtonPressed(playbackURL: URL?) {
        self.playbackURL = playbackURL
        self.performSegue(withIdentifier: "playVideo", sender: nil)
    }
    
    func editButtonPressed(postID: String){
        self.performSegue(withIdentifier: "editPostContent", sender: nil)
    }

    
    func editPostButtonPressed(){
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= 200
        }
        UserService.tags(for: User.current){ (tags) in
            self.tags = tags
        }
    }
    
    func savePostButtonPressed() {
        //PostService.updatePostTags(id: postId,tags: tagsArr)
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
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
            let calendar = Calendar.current
            let firstPost = posts.first?.timeStamp
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
            if monthDate!.isInSameMonth(date: self.currentPostDate!) && monthDate!.isInSameYear(date: self.currentPostDate!) {
                //cell.colorArrow(day: self.currentPostDate!)
                cell.drawArrow(day: self.currentPostDate!)
            } else {
                //unnecessary clearing on first pass. Might be necessary later..
                cell.clearArrow()
            }
            return cell
        } else {
            preconditionFailure("Unknown collection view!")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            //clear current arrow
            let previousCellIndexPath = IndexPath(row: self.currentPostMonth, section: 0)
            
            //get current post for timestamp
            let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
            let post = posts[Int(currentIndex)]
            self.currentPostId = post.id
            self.pageControl.currentPage = Int(currentIndex)

            //only clear cell arrow if it is already in an existing cell. Otherwise it will get cleared in prepareForReuse
            if let optionalCell = self.timeline.cellForItem(at: previousCellIndexPath) {
                let cell = optionalCell as! TimelineMonthViewCell
                cell.clearArrow()
            } else {
                print("cell not loaded")
            }
            
            let firstPost = posts.first?.timeStamp
            let firstOfFirstMonth = firstPost?.startOfMonth()
            let diff = post.timeStamp.months(from: firstOfFirstMonth!)
            self.currentPostMonth = diff
            let monthCellIndexPath = IndexPath(row: diff, section: 0)
            
            if self.timeline.indexPathsForVisibleItems.contains(monthCellIndexPath) {
                print("nothing")
//                self.rightArrow.isHidden = true
//                self.leftArrow.isHidden = true
//                self.backInRange = true
            } else {
                self.timeline.scrollToItem(at: monthCellIndexPath, at: .centeredHorizontally, animated: true)
//                if backInRange == true {
//                    if post.timeStamp > self.currentPostDate! {
//                        self.rightArrow.isHidden = false
//                        self.backInRange = false
//                    } else {
//                        self.leftArrow.isHidden = false
//                        self.backInRange = false
//                    }
//                }
            }
            
            self.currentPostDate = post.timeStamp
            //only draw cell arrow if the cell exists
            if let optionalCell = self.timeline.cellForItem(at: monthCellIndexPath) {
                let cell = optionalCell as! TimelineMonthViewCell
                cell.drawArrow(day:post.timeStamp)
            }
        } else if scrollView == self.timeline {
            print("timeline stopped scrolling")
            if self.timeline.indexPathsForVisibleItems.contains(IndexPath(row:self.currentPostMonth, section: 0)){
                print("visible indexpaths contains the currentPostMonth")
//                self.rightArrow.isHidden = true
//                self.leftArrow.isHidden = true
//                self.backInRange = true
            }
        }
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
        if let controller = segue.destination as? AVPlayerViewController {
            controller.player = AVPlayer(url: self.playbackURL!)
            controller.player?.play()
        } else if let controller = segue.destination as? EditPostContentViewController {
            controller.postAttrs = editPostAttributes
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
    }
    @IBAction func unwindToPosts(sender: UIStoryboardSegue) {
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

