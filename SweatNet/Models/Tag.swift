//
//  Tag.swift
//  SweatNet
//
//  Created by Alex on 5/8/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation
import UIKit

class Tag {
    var id: String?
    var title: String
    var latestThumbnailURL: String
    var latestUpdate: Date
    var color: [CGFloat]
    
    init(title: String,latestThumbnailURL: String, latestUpdate: Date, color: [CGFloat]){
        self.title = title
        self.latestThumbnailURL = latestThumbnailURL
        self.latestUpdate = latestUpdate
        self.color = color
    }
    init?(dictionary: [String : Any]) {
        guard let title = dictionary["title"] as? String,
            let id = dictionary["id"] as? String,
            let latestThumbnailURL = dictionary["latestThumbnailURL"] as? String,
            let latestUpdate = dictionary["latestUpdate"] as? Date,
            let color = dictionary["color"] as? [CGFloat]
            else {return nil}

        self.id = id
        self.title = title
        self.latestThumbnailURL = latestThumbnailURL
        self.latestUpdate = latestUpdate
        self.color = color
    }
    var dictValue: [String: Any] {
        return ["title": title,"latestThumbnailURL":latestThumbnailURL,"latestUpdate":latestUpdate,"color":color]
    }
}
