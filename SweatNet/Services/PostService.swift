//
//  PostServiceFirestore.swift
//  SweatNet
//
//  Created by Alex on 5/9/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation
import AVFoundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

struct PostService {
    
    static func updatePostNotes(id: String,notes:String){
        let currentUser = User.current
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("posts").document(id)
        docRef.updateData([
            "notes": notes
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated!")
            }
        }

        
    }
    static func createImagePost(image: UIImage, timeStamp: Date, tagTitle: String, notes: String) {
        let imageRef = StorageReference.postImageReference(timeStamp:timeStamp)
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            uploadThumbnail(urlString: urlString, timeStamp: timeStamp, thumbnailImage: image, tagTitle: tagTitle, notes: notes,isVideo: false)
        }
    }
    
    static func createVideoPost(video: URL, timeStamp: Date, thumbnailImage: UIImage, tagTitle: String, notes: String) {
        let videoRef = StorageReference.postVideoReference(timeStamp: timeStamp)
        StorageService.uploadVideo(video as NSURL, at: videoRef){ (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            uploadThumbnail(urlString: urlString, timeStamp: timeStamp, thumbnailImage: thumbnailImage, tagTitle: tagTitle, notes: notes, isVideo: true)
        }
    }
    
    private static func uploadThumbnail(urlString: String, timeStamp: Date, thumbnailImage: UIImage, tagTitle: String, notes: String, isVideo: Bool){
        let thumbnailRef = StorageReference.postThumbnailReference(timeStamp: timeStamp)
        StorageService.uploadImage(thumbnailImage, at: thumbnailRef){ (downloadURL) in
            guard let thumbnailURL = downloadURL else {
                return
            }
            let thumbnailURLString = thumbnailURL.absoluteString
            
            create(forURLString: urlString, thumbnailURLString: thumbnailURLString, tagTitle: tagTitle, Notes: notes, isVideo: isVideo,timeStamp: timeStamp)
        }
    }
    
    private static func create(forURLString urlString: String, thumbnailURLString: String, tagTitle: String, Notes: String,isVideo:Bool,timeStamp: Date) {
        
        let currentUser = User.current
        let tagDict = [tagTitle: UInt64(Date().timeIntervalSince1970)]        
        let post = Post(mediaURL: urlString, tagDict: tagDict, notes: Notes, timeStamp: timeStamp, isVideo:isVideo, thumbnailURL: thumbnailURLString)
        print(post.timeStamp,"creationDate")
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("posts")
        docRef.addDocument(data: post.dictValue) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                AudioServicesPlayAlertSound(SystemSoundID(1322))
                print("Document successfully written!")
                TagService.ifTagExists(title: tagTitle, thumbnailURL: thumbnailURLString)
            }
        }
    }
}
