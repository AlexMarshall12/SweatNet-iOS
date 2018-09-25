//
//  TwentyEightDayMonthViewCell.swift
//  SweatNet
//
//  Created by Alex on 6/18/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

class TimelineMonthViewCell: UICollectionViewCell {

    @IBOutlet weak var dayTicks: UIStackView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var yearLine: UIView!
    @IBOutlet weak var arrowTicks: UIStackView!
    
    var currentQueryTags: [String]?
    
    var year: Int? {
        didSet {
            self.yearLabel.text = String(describing: year!)
        }
    }
    var month: Int? {
        didSet {
            if month == 1 {
                yearLabel.isHidden = false
                yearLine.isHidden = false
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        yearLabel.isHidden = true
        yearLine.isHidden = true
        
        for each_view in self.dayTicks.subviews {
            each_view.backgroundColor = UIColor.clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for _ in 0 ..< 31 {
            let tick = UIView()
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tick.addGestureRecognizer(tap)
            self.dayTicks?.addArrangedSubview(tick)
//            let arrowImage = UIImage(named: "Up Arrow")
//            let arrowImageView = UIImageView(image: arrowImage)
//            arrowImageView.clipsToBounds = false
//            self.arrowTicks.addArrangedSubview(arrowImageView)
        }
    }
    
    func setDays(num: Int){
        for i in 0 ..< num {
            self.dayTicks.arrangedSubviews[i].isHidden = false
        }
        for i in num ..< 31 {
            self.dayTicks.arrangedSubviews[i - 1].isHidden = true
        }
    }
    
    func colorViews(monthPosts: [Post]){
        for post in monthPosts {
            let dayIndex = Calendar.current.component(.day, from: post.timeStamp)
            var out: UIColor?
            for tag in post.tags.keys {
                if (self.currentQueryTags?.contains(tag))!{
                    out = tagColors.sharedInstance.dict[tag]
                }
            }
            let tick = dayTicks.arrangedSubviews[dayIndex]
            tick.backgroundColor = out ?? UIColor.black
        }
    }
    
    func clearArrow(){
        for tick in self.dayTicks.subviews {
            tick.layer.sublayers = nil
        }
    }
    
    func colorArrow(day:Date){
        let dayIndex = Calendar.current.component(.day, from: day)
        let tick = dayTicks.arrangedSubviews[dayIndex]
        tick.backgroundColor = UIColor(red:0.99, green:0.13, blue:0.25, alpha:1.0)
    }
    
    func drawArrow(day:Int){
        //let dayIndex = Calendar.current.component(.day, from: day)
        let tick = dayTicks.arrangedSubviews[day]
        let tickBounds = tick.bounds
        let start_x = tickBounds.origin.x
        let start_y = tickBounds.origin.y
//        let top_width = tickBounds.width
//        let tick_height = tickBounds.height
        let top_width = CGFloat(2.0)
        let tick_height = CGFloat(20.0)
        let tip_height = CGFloat(10)
        let tip_flare = CGFloat(6)
        let arrowLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: start_x, y: start_y + tick_height))
        path.addLine(to: CGPoint(x: start_x + top_width,y: start_y + tick_height))
        path.addLine(to: CGPoint(x: start_x + top_width + tip_flare,y: start_y+tick_height+tip_height))
        path.addLine(to: CGPoint(x: start_x - tip_flare,y: start_y + tick_height + tip_height))
        path.close()
        arrowLayer.path = path.cgPath
        arrowLayer.fillColor = UIColor(red:0.99, green:0.13, blue:0.25, alpha:1.0).cgColor
        tick.layer.addSublayer(arrowLayer)
    }
    
    @objc func handleTap(_ gesture: UIGestureRecognizer){
        if let tick = gesture.view {
            if tick.superview == self.dayTicks {
                if let idx = self.dayTicks.arrangedSubviews.index(of: tick) {
                    print("monthd", self.month!,"day",idx,"year", self.year!)
                }
            }
        }
    }

}
