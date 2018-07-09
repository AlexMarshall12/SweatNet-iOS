//
//  TagServiceFirestore.swift
//  SweatNet
//
//  Created by Alex on 5/8/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct TagService {
    
    static func ifTagExists(title:String,thumbnailURL:String, creationDate: Date){
        let currentUser = User.current
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags").document(title)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //update Tag
                let latestUpdate: Date?
                let tag = Tag(title: document.data()!["title"] as! String, latestThumbnailURL: document.data()!["latestThumbnailURL"] as! String, latestUpdate: document.data()!["latestUpdate"] as! Date, color: document.data()!["color"] as! [CGFloat])
                if creationDate > tag.latestUpdate {
                    latestUpdate = creationDate
                } else {
                    latestUpdate = tag.latestUpdate
                }
                updateTag(title: title, thumbnailURL: thumbnailURL, latestUpdate: latestUpdate!)
            } else {
                createTag(title: title, thumbnailURL: thumbnailURL, latestUpdate: creationDate)
            }
        }
    }
    
    static func updateTag(title: String, thumbnailURL: String, latestUpdate: Date) {
        let currentUser = User.current
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags").document(title)
        docRef.updateData([
            "latestUpdate": Date(),
            "latestThumbnailURL": thumbnailURL
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    static func createTag(title: String,thumbnailURL:String, latestUpdate: Date) {
        let currentUser = User.current
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags").document(title)
        let tagColor = UIColor.random()
        let colorArr = [tagColor.redValue,tagColor.blueValue,tagColor.greenValue]
        let tag = Tag(title: title,latestThumbnailURL: thumbnailURL, latestUpdate: latestUpdate, color: colorArr)
        docRef.setData(tag.dictValue) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}

