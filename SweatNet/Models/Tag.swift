//
//  Tag.swift
//  SweatNet
//
//  Created by Alex on 4/23/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Tag {
    var key: String?
    let title: String
    let latestThumbnailURL: String
    let latestUpdate: UInt64
    
    init(title: String,latestThumbnailURL: String, latestUpdate: UInt64){
        self.title = title
        self.latestThumbnailURL = latestThumbnailURL
        self.latestUpdate = latestUpdate
    }
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any],
            let title = dict["title"] as? String,
            let latestThumbnailURL = dict["latestThumbnailURL"] as? String,
            let latestUpdate = dict["latestUpdate"] as? UInt64
            else { return nil }
        self.key = snapshot.key
        self.title = title
        self.latestThumbnailURL = latestThumbnailURL
        self.latestUpdate = latestUpdate
    }
    var dictValue: [String: Any] {
        return ["title": title,"latestThumbnailURL":latestThumbnailURL,"latestUpdate":latestUpdate]
    }
}
