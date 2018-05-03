//
//  PostService.swift
//  SweatNet
//
//  Created by Alex on 3/13/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {

    static func createImagePost(image: UIImage, tagTitle: String, notes: String) {
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            create(forURLString: urlString, tagTitle: tagTitle, Notes: notes)
        }
    }

    static func createVideoPost(video: URL, tagTitle: String, notes: String) {
        let videoRef = StorageReference.newPostVideoReference()
        StorageService.uploadVideo(video as NSURL, at: videoRef){ (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            create(forURLString: urlString, tagTitle: tagTitle, Notes:notes)
        }
    }
    private static func create(forURLString urlString: String, tagTitle: String, Notes: String) {
        
        // create new post in database
        // 1
        let currentUser = User.current
        // 2
        let Tags = [tagTitle]
        let post = Post(mediaURL: urlString, tags: Tags, notes: Notes)
        // 3
        let dict = post.dictValue
        // 4
        let postRef = Database.database().reference().child("posts").child(currentUser.uid).childByAutoId()
        // 5
        postRef.updateChildValues(dict)
    }
}
