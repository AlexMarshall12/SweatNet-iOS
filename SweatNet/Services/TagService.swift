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
    
    static func ifTagExists(title:String,thumbnailURL:String){
        let currentUser = User.current
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags").document(title)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //update Tag
                updateTag(title: title, thumbnailURL: thumbnailURL)
            } else {
                createTag(title: title, thumbnailURL: thumbnailURL)
            }
        }
    }
    
    static func updateTag(title: String, thumbnailURL: String) {
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
    static func createTag(title: String,thumbnailURL:String) {
        let currentUser = User.current
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags").document(title)
        let tag = Tag(title: title,latestThumbnailURL: thumbnailURL, latestUpdate: Date())
        docRef.setData(tag.dictValue) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}

