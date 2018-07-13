//
//  UserServiceFirestore.swift
//  SweatNet
//
//  Created by Alex on 5/7/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

//
//  UserService.swift
//  SweatNet
//
//  Created by Alex on 3/11/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

struct UserService {
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let dataDescription = document.data() else {return}
                print(dataDescription)
                print(type(of: dataDescription))
                guard let user = User(dictionary: dataDescription) else { return }
                print("user")
                print(user)
                completion(user)
            } else {
                print("User does not exist")
                completion(nil)
            }
        }
    }
    
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let newUserRef = Firestore.firestore().collection("users").document(firUser.uid)
        let user = User(uid: firUser.uid, username: username, storage: 0)
        print(user.dictValue)
        newUserRef.setData(user.dictValue) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    completion(nil)
                } else {
                    print("Document successfully written!")
                    //have to run completion with the newly created user....
                    completion(user)
                }
        }
    }
    static func posts(for user: User,tagString: String, completion: @escaping (([Post],[String])) -> Void) {
        let docRef = Firestore.firestore().collection("users").document(user.uid).collection("posts").whereField("tags.\(tagString)", isGreaterThan: 0).order(by: "tags.\(tagString)")
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var posts = [Post]()
                var postIds = [String]()
                for document in querySnapshot!.documents {
                    let post = Post(mediaURL: document.data()["mediaURL"] as! String, tagDict: document.data()["tags"] as! [String:UInt64], notes: document.data()["notes"] as! String, timeStamp: document.data()["timeStamp"] as! Date, isVideo: document.data()["isVideo"] as! Bool, thumbnailURL: document.data()["thumbnailURL"] as! String)
                    postIds.append(document.documentID)
                    posts.append(post)
                }
                completion((posts,postIds))
            }
        }
    }
    
    static func tags(for user: User, completion: @escaping ([Tag]) -> Void){
        let docRef = Firestore.firestore().collection("users").document(user.uid).collection("tags")
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var tags = [Tag]()
                for document in querySnapshot!.documents {
                    let tag = Tag(title: document.data()["title"] as! String, latestThumbnailURL: document.data()["latestThumbnailURL"] as! String, latestUpdate: document.data()["latestUpdate"] as! Date, color: document.data()["color"] as! [CGFloat])
                    tags.append(tag)
                }
                completion(tags)
            }
        }
    }
    
    static func updateStorage(forUID uid: String, size: Int64) {
        var s = 0
        if isKeyPresentInUserDefaults(key: "total_storage") == true {
            s = UserDefaults.standard.integer(forKey: "total_storage")
        } else {
            s = 0
        }
        let newStorage = Int64(s) + size
        UserDefaults.standard.set(newStorage,forKey:"total_storage")
        
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.updateData([
            "totalStorage": newStorage
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated!")
            }
        }

    }

}
