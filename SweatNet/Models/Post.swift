//
//  File.swift
//  SweatNet
//
//  Created by Alex on 5/8/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//
import Foundation
class Post {
    var id: String?
    var mediaURL: String
    var timeStamp: Date
    var tags: [String:UInt64]
    var notes: String
    
    init(mediaURL: String, tagDict: [String:UInt64], notes: String,timeStamp:Date){
        self.mediaURL = mediaURL
        self.tags = tagDict
        self.notes = notes
        self.timeStamp = timeStamp
    }
    init?(dictionary: [String : Any]) {
        guard let mediaURL = dictionary["mediaURL"] as? String,
            let id = dictionary["id"] as? String,
            let notes = dictionary["notes"] as? String,
            let timeStamp = dictionary["timeStamp"] as? Date,
            let tags = dictionary["tags"] as? [String:UInt64]
        else {return nil}
        
        self.id = id
        self.mediaURL = mediaURL
        self.notes = notes
        self.timeStamp = timeStamp
        self.tags = tags
    }
    var dictValue: [String: Any] {
        return [
            "mediaURL":mediaURL,
            "notes" : notes,
            "timeStamp" : timeStamp,
            "tags": tags
        ]
    }
}

