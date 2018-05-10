//
//  TagService.swift
//  SweatNet
//
//  Created by Alex on 4/23/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import UIKit

struct TagServiceBack {

    static func ifTagExists(id:String,title:String,latestThumbnailImage:UIImage,latestUpdate:UInt64){
        let currentUser = User.current
        let ref = Database.database().reference().child("tags").child(currentUser.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(id){
                print("tag exists")
                uploadThumbnail(image: latestThumbnailImage, title: title, latestUpdate: latestUpdate)
                //update tag
            } else {
                print("tag does not exist")
                uploadThumbnail(image: latestThumbnailImage,title:title,latestUpdate:latestUpdate)
                //let tag = Tag(title:title,latestThumbnailURL:thumbnailURL,latestUpdate:latestUpdate)
                //let dict = tag.dictValue
                //ref.updateChildValues(dict)
            }
        })
    }
    static func uploadThumbnail(image: UIImage,title:String,latestUpdate:UInt64) -> Void {
        let thumbnailRef = StorageReference.newThumbnailImageReference()
        StorageService.uploadImage(image, at: thumbnailRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            createTag(latestThumbnailURL: urlString,title: title,latestUpdate: latestUpdate)
        }
    }
    static func createTag(latestThumbnailURL:String,title: String,latestUpdate:UInt64) {
        let currentUser = User.current
        let ref = Database.database().reference().child("tags").child(currentUser.uid).childByAutoId()
        let tag = Tag(title:title,latestThumbnailURL:latestThumbnailURL,latestUpdate:latestUpdate)
        let dict = tag.dictValue
        ref.updateChildValues(dict)
    }

}
