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
import HSLuvSwift

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
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("tag successfully updated")
            }
        }
    }
    static func createTag(title: String,thumbnailURL:String, latestUpdate: Date) {
        let currentUser = User.current
        let phi = (1 + pow(5,0.5)) / 2
        let docRef = Firestore.firestore().collection("users").document(currentUser.uid).collection("tags").document(title)
        var h = 0.0
        if let seed = UserDefaults.standard.object(forKey: "color_seed") as? Double {
            h = seed
        } else {
            h = Double(arc4random()) / Double(UInt32.max)
        }
        h += phi
        h = h.truncatingRemainder(dividingBy: 2*Double.pi)
        let tagColor = UIColor(hue: Double(h*(180/Double.pi)), saturation: 95.0, lightness: 60.0, alpha: 1.0)
        
        let seed = h
        UserDefaults.standard.set(seed,forKey:"color_seed")
        
        let colorArr = [tagColor.redValue,tagColor.blueValue,tagColor.greenValue]
        let tag = Tag(title: title,latestThumbnailURL: thumbnailURL, latestUpdate: latestUpdate, color: colorArr)
        docRef.setData(tag.dictValue) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
}

