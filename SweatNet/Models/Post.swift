//
//  Post.swift
//  SweatNet
//
//  Created by Alex on 3/14/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post {
    var key: String?
    let mediaURL: String
    let creationDate: Date
    let tags: [String: UInt64]
    let notes: String
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let mediaURL = dict["media_url"] as? String,
            let createdAgo = dict["created_at"] as? TimeInterval,
            let tags = dict["tags"] as? [String: UInt64],
            let notes = dict["notes"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.mediaURL = mediaURL
        self.tags = tags
        self.notes = notes
        self.creationDate = Date(timeIntervalSince1970: createdAgo)
    }
    
    init(mediaURL: String, tags: Array<String>, notes: String) {
        self.mediaURL = mediaURL
        let creationDate = Date()
        self.creationDate = creationDate
        self.notes = notes
        var tagDict = [String: UInt64]()
        for tag in tags {
            tagDict[tag] = UInt64(creationDate.timeIntervalSince1970)
        }
        self.tags = tagDict
    }

    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        return ["media_url" : mediaURL,
                "tags": tags,
                "notes": notes,
                "created_at" : createdAgo]
    }
    
}
