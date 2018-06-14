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

class TagViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SNPostViewCellDelegate {
    
    var posts = [Post]()
    var postIds = [String]()
    var dayTicks = [Date:UIView]()
    var playbackURL: URL?
    var tagTitle: String!
    private var dataSources: [IndexPath : dayCellDelegates] = [:]
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timeline: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserService.posts(for: User.current,tagString: self.tagTitle!) { (postStuff) in
            let posts = postStuff.0
            self.postIds = postStuff.1
            self.posts = posts.sorted(by: {
                $0.timeStamp.compare($1.timeStamp) == .orderedAscending
            })
            print(self.posts,"mypost")
            self.timeline.dataSource = self
            self.collectionView.dataSource = self
            self.timeline.delegate = self
            self.collectionView.delegate = self
            //self.timeline.collectionViewLayout.invalidateLayout()
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
            print("mypost",self.posts)
            
            return posts.count
        } else if collectionView == self.timeline {
            let first = posts.first?.timeStamp
            let last = posts.last?.timeStamp
            let months = last?.months(from: first!) ?? 0
            print("no of months",months)

            if let diff = last?.months(from: first!), diff <= 5 {
                return months + 5-diff + 12
            } else {
                return months + 1 + 12
            }
        } else {
            preconditionFailure("Unknown collection view!")
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        print("exampleTextView: END EDIT")
    }
    func myCustomCellDidUpdate(cell: SNPostViewCell, newContent: String) { // do stuff on your view controller with the cell or the new content
        let index = self.collectionView.indexPath(for: cell)?.item
        let postId = postIds[index!]
        PostService.updatePostNotes(id: postId, notes: newContent)
    }
    func playButtonPressed(playbackURL: URL?) {
        self.playbackURL = playbackURL
        self.performSegue(withIdentifier: "playVideo", sender: nil)
    }

    func dates(_ dates: [Post], withinMonth month: Int, withinYear year: Int) -> [Post] {
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.month,.year]
        print(components,"components")
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SNPostViewCell
            cell.isVideo = post.isVideo
            cell.delegate = self
            cell.notes.text = post.notes
            cell.thumbnailURL = URL(string: post.thumbnailURL)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell.timeStampLabel.text = formatter.string(from: post.timeStamp)
            cell.mediaURL = URL(string: post.mediaURL)
            cell.notes.topAnchor.constraint(equalTo: cell.thumbnail.bottomAnchor,constant: 0.0).isActive = true
            return cell
        } else if collectionView == self.timeline {
            let index = indexPath.row
            print(index,"index")
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            let firstPost = posts.first?.timeStamp
            let month = calendar.date(byAdding: .month, value: index, to: firstPost!)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SNMonthViewCell", for: indexPath) as! SNMonthViewCell
            cell.monthLabel.text = dateFormatter.string(from: month!)
            cell.monthLabel.textAlignment = .center
            return cell
        } else {
            preconditionFailure("Unknown collection view!")
        }
    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == self.collectionView {
//            let cell = collectionView.cellForItem(at: indexPath)
//            print(cell,"selected")
//            let post = posts[indexPath.row]
//            if post.isVideo == true {
//                self.performSegue(withIdentifier: "playVideo", sender: nil)
//            } else {
//                print("is image. might go full screen one day here")
//            }
//        } else if collectionView == self.timeline {
//            print("touched timeline")
//        } else {
//            preconditionFailure("Unknown collection view!")
//        }
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
            //adjust constraint of tracerpin
            //4th video should find 4th bar.
            let post = posts[Int(currentIndex)]
            for (_,tick) in self.dayTicks {
                tick.layer.sublayers = nil
            }
            let day = Calendar.current.startOfDay(for: post.timeStamp)
            print(self.dayTicks,"dayTicks")
            if let tick = self.dayTicks[day], let tickBounds = self.dayTicks[day]?.bounds {
                let start_x = tickBounds.origin.x
                let start_y = tickBounds.origin.y
                let top_width = tickBounds.width
                let tick_height = tickBounds.height
                let tip_height = CGFloat(10)
                let tip_flare = CGFloat(10)
                let arrowLayer = CAShapeLayer()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: start_x, y: start_y))
                path.addLine(to: CGPoint(x: start_x + top_width,y: start_y))
                path.addLine(to: CGPoint(x: start_x + top_width,y: start_y + tick_height))
                path.addLine(to: CGPoint(x: start_x + top_width + tip_flare,y: start_y+tick_height+tip_height))
                path.addLine(to: CGPoint(x: start_x - tip_flare,y: start_y + tick_height + tip_height))
                path.addLine(to: CGPoint(x: start_x,y: start_y+tick_height))
                path.close()
                arrowLayer.path = path.cgPath
                arrowLayer.fillColor = UIColor(red:0.99, green:0.13, blue:0.25, alpha:1.0).cgColor
                tick.layer.addSublayer(arrowLayer)
            }
        } else {
            print(scrollView, "timeline collection view")
        }
       

    }

    func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath){
        if collectionView == self.timeline{
            guard let monthViewCell = cell as? SNMonthViewCell else  {
                return
            }
            if let dayDelegatesInstance = dataSources[indexPath] {
                monthViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: dayDelegatesInstance)
            } else {
                let index = indexPath.item
                let firstPost = self.posts.first?.timeStamp
                let monthDate = Calendar.current.date(byAdding: .month, value: index, to: firstPost!)
                let monthInt = Calendar.current.component(.month, from: monthDate!)
                let yearInt = Calendar.current.component(.year, from: monthDate!)
                let postDates = dates(self.posts, withinMonth: monthInt, withinYear: yearInt)
                let dayDelegatesInstance = dayCellDelegates(firstDay: (monthDate?.startOfMonth())!, monthPosts:postDates)
                dataSources[indexPath] = dayDelegatesInstance
                monthViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: dayDelegatesInstance)
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
            return CGSize(width: collectionView.bounds.size.width/5, height: 40)
        }
    }

//    func dates(_ dates: [Date], withinMonth month: Int) -> [Date] {
//        let calendar = Calendar.current
//        let components: Set<Calendar.Component> = [.month]
//        let filtered = dates.filter { (date) -> Bool in
//            calendar.dateComponents(components, from: date).month == month
//        }
//        return filtered
//    }
    @objc func tapBar(_ sender:UITapGestureRecognizer) {
        let bar = sender.view
        print("bar tapped")
        //print(bar?.frame.origin.x)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "playVideo" {
            let destination = segue.destination as! AVPlayerViewController
            destination.player = AVPlayer(url: self.playbackURL!)
            destination.player?.play()
        }
    }
    @IBAction func unwindToPosts(sender: UIStoryboardSegue) {
    }

//    func setupStack() {
//        let truncated = Calendar.current.startOfDay(for: Date())
//        let calendar = Calendar.current
//        var startDate: Date
//        //if less than 6 months, end date is 5 months from now
//        //if 3 months? end date is 2 months from newest date...
//        //end date = end date + (5 - (end - start))
//        let endDate = Date() // last date
//        let first = posts.first?.timeStamp
//        let firstEpoch = first?.timeIntervalSince1970
//        let diff = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
//        let last = posts.last?.timeStamp
//        let nearest_month = first!.endOfMonth()
//        var date = nearest_month
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "LLLL"
//        while date <= last! {
//            let label = UILabel()
//            date = calendar.date(byAdding: .month, value: 1, to: date)!
//            let percentageDisplaced = date.timeIntervalSince1970 - firstEpoch!/diff
//            label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//            label.text = dateFormatter.string(from: date)
//            //label.centerXAnchor.constraint(equalTo: view.trailingAnchor,constant: 0,multiplier:0.5)
//            dateLabels.addSubview(label)
//        }
//        if let diff = first?.months(from: last!), diff <= 5 {
//            let endDate = calendar.date(byAdding: .month, value: 5-diff, to: first!)
//        } else {
//            let endDate = last
//        }
//        var date = first!
//
//        for post in posts {
//            if
//        }
//        while date <= endDate {
//            let line = UIView()
//            date = calendar.date(byAdding: .day, value: 1, to: date)!
//            if postDates.contains(date) {
//                print("contained")
//                line.backgroundColor = UIColor.blue
//            } else {
//                print("not contained")
//                line.backgroundColor = UIColor.clear
//            }
//            stackView.addSubview(line)
//        }
//        var days: Int = 0
//        var postDates = [Date]()
//        var firstDate: Bool = true
//        for post in posts {
//            postDates.append(post.timeStamp)
//            let date = post.timeStamp
//            let midnight = Calendar.current.startOfDay(for: date)
//            postDates.append(midnight)
//            if firstDate == true {
//                let startDate = midnight
//                firstDate = false
//            }
//        }
//        var date = startDate
//        let diff = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
//        let offset = startDate.offset(from: Date())
//        let previous = date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "LLLL"
//        switch offset.last! {
//        case "y":
//
//            switch offset.prefix! {
//            case 1:
//                //year and every 4 months
//                var counter: Int = 0
//                while date <= endDate {
//                    date = calendar.date(byAdding: .month, value: 4, to: date)!
//                    let displacementPercentage = (date.timeIntervalSince1970 - startDate.timeIntervalSince1970)/diff
//                    let label = UILabel()
//                    label.bottomAnchor.constraint(equalTo: dateLabels.topAnchor).isActive = true
//                    label.centerXAnchor.constraint(equalTo: dateLabels.tra, multiplier: CGFloat(displacementPercentage)).isActive = true
//                    if calendar.component(.month, from: date) == 0 {
//                        label.text = dateFormatter.string(from: date)
//                    } else {
//                        label.text = dateFormatter.string(from: date)
//                    }
//                    dateLabels.addSubview(label)
//                }
//            case 2,3:
//                while date <= endDate {
//                    date = calendar.date(byAdding: .month, value: 6, to: date)!
//                    dateLabel(displacement: )
//                }
//                //year and every 6 months
//            default:
//                //every year
//            }
//
//        case "M":
//            //set start date to first date
//            switch offset.prefix! {
//            case 1:
//                //month and 5 day increments
//            case 2,3:
//                //month and 15 day increments
//            case 4,5,6:
//                //month only
//            default:
//                //set start date to 6 months before end date
//            }
//        case "w":
//            make_labels(every: "w")
//        }
//        while date <= endDate {
//            date = calendar.date(byAdding: .day, value: 1, to: date)!
//
//            //case: at least a month
//            if calendar.component(.day, from: date) == 0 { dateLabel(bin:days,dateString: calendar.component(.month, from date)) }
//
//            //case: less than month but more than week
//            if calendar.component(.day, from: date) ==
//            let line = UIView()
//            bins[date] = days
//            days = days + 1
//            if postDates.contains(date!) {
//                print("contained")
//                line.backgroundColor = UIColor.blue
//            } else {
//                print("not contained")
//                line.backgroundColor = UIColor.clear
//            }
//            stackView.addArrangedSubview(line)
//        }
//    }
//    func dateLabel(displacement: Int,dateString: String){
//        let label = UILabel()
//        label.bottomAnchor.constraint(equalTo: dateLabels.topAnchor).isActive = true
//        label.text = dateString
//        label.centerXAnchor.constraint(equalTo: dateLabels.leadingAnchor, constant: CGFloat(bin)).isActive = true
//        dateLabels.addSubview(label)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class dayCellDelegates: NSObject,UICollectionViewDataSource, UICollectionViewDelegate {
    let firstDay: Date
    let monthPosts: [Post]
    
    init(firstDay: Date, monthPosts: [Post]){
        self.firstDay = firstDay
        self.monthPosts = monthPosts
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: self.firstDay)!
        return range.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let range = Calendar.current.range(of: .day, in: .month, for: self.firstDay)!
        return CGSize(width: collectionView.bounds.size.width/CGFloat(range.count), height: collectionView.bounds.size.height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell",
                                                      for: indexPath as IndexPath)
        let components: Set<Calendar.Component> = [.day]
        //let contained = self.postDates.reduce(false,{Calendar.current.dateComponents(components, from: $0).day == indexPath.item})
        let filtered = self.monthPosts.filter { (post) -> Bool in
            Calendar.current.dateComponents(components, from: post.timeStamp).day == indexPath.item
        }
        cell.layer.borderWidth = 0.1
        if filtered.isEmpty == false {
            cell.backgroundColor = UIColor(red:0.15, green:0.67, blue:0.93, alpha:1.0)
        }
        return cell
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

//            case 30:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "30DayMonthCell", for: indexPath) as! thirtyDayMonthViewCell
//            case 28:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "28DayMonthCell", for: indexPath) as! twentyEightDayMonthViewCell
//            default:
//                print("found month with weird number of days")
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "31DayMonthCell", for: indexPath) as! thirtyOneDayMonthViewCell
//            }
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MMM"
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineMonthCellReuseIdentifier, for: indexPath) as! SNTimelineMonthViewCell
//            let firstPost = posts.first?.timeStamp
//            let month = Calendar.current.date(byAdding: .month, value: index, to: firstPost!)
//            let monthInt = Calendar.current.component(.month, from: month!)
//            let yearInt = Calendar.current.component(.year, from: month!)
//            let postsInMonthAndYear = dates(posts, withinMonth: monthInt, withinYear: yearInt)
//            print(postsInMonthAndYear,"postsInMonthAndYear")
//            if postsInMonthAndYear.isEmpty {
//                let background = UIView()
//                background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//                background.frame = timeline.bounds
//                background.backgroundColor = UIColor.gray
//                cell.layer.borderColor = UIColor.black.cgColor
//
//                cell.layer.borderWidth = 1
//                //cell.dayTicks.addSubview(background)
//            } else {
//                cell.layer.borderColor = UIColor.black.cgColor
//
//                cell.layer.borderWidth = 1
//                let tickLayer = CAShapeLayer()
//                tickLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: cell.layer.bounds.width, height: cell.layer.bounds.height), cornerRadius: 5).cgPath
//                tickLayer.fillColor = UIColor(red:0.99, green:0.13, blue:0.25, alpha:1.0).cgColor
//                cell.layer.addSublayer(tickLayer)
//
//                if let start = month?.startOfMonth(), let end = month?.endOfMonth(), let stackView = cell.dayTicks {
//                    var date = start
//                    //timeline.addSubview(background)
//                    while date <= end {
//                        let line = UIView()
//                        if posts.contains(where: { Calendar.current.isDate(date, inSameDayAs: $0.timeStamp) }) {
//                            print("Found blue", date)
//                            line.backgroundColor = UIColor(red:0.15, green:0.67, blue:0.93, alpha:1.0)
//                            let tapGuesture = UITapGestureRecognizer(target: self, action:  #selector (self.tapBar (_:)))
//                            line.isUserInteractionEnabled = true
//                            line.addGestureRecognizer(tapGuesture)
//                            self.dayTicks[date] = line
//                        } else {
//                            line.backgroundColor = UIColor.clear
//                        }
//                        stackView.addArrangedSubview(line)
//                        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
//                    }
//                }
//        }
//            if Calendar.current.component(.month, from: month!) == 12 {
//                let yearLabel = UILabel()
//                yearLabel.text = "20"
//                yearLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 0.0).isActive = true
//                cell.monthLabel.addSubview(yearLabel)
//            }
//            if Calendar.current.component(.month, from: month!) == 01 {
//                let yearLabel = UILabel()
//                yearLabel.text = String(String(Calendar.current.component(.year,from: month!)).suffix(2))
//                yearLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor,constant:0.0).isActive = true
//                cell.monthLabel.addSubview(yearLabel)
//            }
//            cell.monthLabel.text = dateFormatter.string(from: month!)
//            cell.monthLabel.textAlignment = .center
//            let background = UIView()
//            background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            background.frame = timeline.bounds
//            background.backgroundColor = UIColor.red

