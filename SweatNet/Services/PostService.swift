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
    
    static func updatePostContent(id: String,notes:String,tags:[String],postDate:Date){
        let currentUser = User.current
        var tagDict: [String:UInt64] = [:]
        for tag in tags {
            tagDict[tag] = UInt64(postDate.timeIntervalSince1970)
        }
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("posts").document(id)
        docRef.updateData([
            "notes": notes,
            "tags":tagDict
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated!")
            }
        }
    }
    static func createImagePost(image: UIImage, timeStamp: Date, tags: [String], notes: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let imageRef = StorageReference.postImageReference(timeStamp:timeStamp)
        StorageService.uploadImage(image, at: imageRef) { (metadata) in
            guard let downloadURL = metadata?.downloadURL(), let size = metadata?.size else {
                return
            }
            UserService.updateStorage(forUID: User.current.uid, size: size)
            let urlString = downloadURL.absoluteString
            uploadThumbnail(urlString: urlString, timeStamp: timeStamp, thumbnailImage: image, tags:tags, notes: notes,isVideo: false)
        }
    }
    
    static func createVideoPost(video: URL, timeStamp: Date, thumbnailImage: UIImage, tags: [String], notes: String) {
        print("creating video post")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let videoRef = StorageReference.postVideoReference(timeStamp: timeStamp)
        StorageService.uploadVideo(video as NSURL, at: videoRef){ (metadata) in
            guard let downloadURL = metadata?.downloadURL(), let size = metadata?.size else {
                return
            }
            print(downloadURL,"downloadURL")
            UserService.updateStorage(forUID: User.current.uid, size: size)
            let urlString = downloadURL.absoluteString
            uploadThumbnail(urlString: urlString, timeStamp: timeStamp, thumbnailImage: thumbnailImage, tags:tags, notes: notes, isVideo: true)
        }
    }
    
    private static func uploadThumbnail(urlString: String, timeStamp: Date, thumbnailImage: UIImage, tags: [String], notes: String, isVideo: Bool){
        let thumbnailRef = StorageReference.postThumbnailReference(timeStamp: timeStamp)
        StorageService.uploadImage(thumbnailImage, at: thumbnailRef){ (metadata) in
            guard let thumbnailURL = metadata?.downloadURL(), let size = metadata?.size else {
                return
            }
            UserService.updateStorage(forUID: User.current.uid, size: size)
            let thumbnailURLString = thumbnailURL.absoluteString
            create(forURLString: urlString, thumbnailURLString: thumbnailURLString, tags:tags, Notes: notes, isVideo: isVideo,timeStamp: timeStamp)
        }
    }
    
    private static func create(forURLString urlString: String, thumbnailURLString: String, tags: [String], Notes: String,isVideo:Bool,timeStamp: Date) {
        
        let currentUser = User.current
        var tagDict: [String:UInt64] = [:]
        for tag in tags {
            tagDict[tag] = UInt64(timeStamp.timeIntervalSince1970)
        }
        let post = Post(mediaURL: urlString, tagDict: tagDict, notes: Notes, timeStamp: timeStamp, isVideo:isVideo, thumbnailURL: thumbnailURLString)
        print(post.timeStamp,"creationDate")
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("posts")
        docRef.addDocument(data: post.dictValue) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                AudioServicesPlayAlertSound(SystemSoundID(1322))
                print("Document successfully written!")
                for (title,_) in tagDict{
                    //Creates new tag or updates it if it already exists...
                    TagService.ifTagExists(title: title, thumbnailURL: thumbnailURLString, creationDate: timeStamp)
                }
            }
        }
    }
}
