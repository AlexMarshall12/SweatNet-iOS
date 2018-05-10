//
//  PostServiceFirestore.swift
//  SweatNet
//
//  Created by Alex on 5/9/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

struct PostService2 {
    
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
        
        let currentUser = User2.current
        let Tags = [tagTitle]
        let tagDict = [tagTitle: UInt64(Date().timeIntervalSince1970)]
        
        let post = Post2(mediaURL: urlString, tagDict: tagDict, notes: Notes,timeStamp: Date())
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("posts")
        docRef.addDocument(data: post.dictValue) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
