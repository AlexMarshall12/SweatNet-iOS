//
//  StorageReference+Post.swift
//  SweatNet
//
//  Created by Alex on 3/14/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation
import FirebaseStorage

extension StorageReference {
    static let dateFormatter = ISO8601DateFormatter()
    
    static func newPostImageReference() -> StorageReference {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
    }
    static func newPostVideoReference() -> StorageReference {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("videos/posts/\(uid)/\(timestamp).mov")
    }
    static func newThumbnailImageReference() -> StorageReference {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("thumbnails/posts/\(uid)/\(timestamp).jpg")
    }
    static func thumnailImageReference(title:String) -> StorageReference {
        let uid = User.current.uid
        return Storage.storage().reference().child("thumbnails/posts/\(uid)/\(title).jpg")
    }
}
