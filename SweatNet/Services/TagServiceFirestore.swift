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

struct TagService2 {
    
    static func ifTagExists(title:String,thumbnailURL:String){
        let currentUser = User2.current
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags").document(title)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //update Tag
                updateTag(title: title)
            } else {
                createTag(title: title, thumbnailURL: thumbnailURL)
            }
        }
    }
    static func uploadThumbnail(title: String, latestThumbnailImage: UIImage) -> Void {
        let thumbnailRef = StorageReference.thumnailImageReference(title: title)
        StorageService.uploadImage(latestThumbnailImage, at: thumbnailRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            ifTagExists(title: title, thumbnailURL: urlString)
        }
    }
    
    static func updateTag(title: String) {
        let currentUser = User.current
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags").document(title)
        docRef.updateData([
            "latestUpdate": Date()
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
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags")
        let tag = Tag2(title: title,latestThumbnailURL: thumbnailURL, latestUpdate: Date())
        docRef.addDocument(data: tag.dictValue) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}

