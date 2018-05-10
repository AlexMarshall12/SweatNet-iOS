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
import FirebaseFirestore

struct UserService2 {
    
    static func show(forUID uid: String, completion: @escaping (User2?) -> Void) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print(dataDescription)
                guard let user = User2(dictionary: ["data":dataDescription]) else { return }
                completion(user)
            } else {
                print("User does not exist")
                completion(nil)
            }
        }
    }
    
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User2?) -> Void) {
        let docRef = Firestore.firestore().collection("users")
        let user = User2(uid: firUser.uid, username: username)
        docRef.addDocument(data: user.dictValue) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    completion(nil)
                } else {
                    print("Document successfully written!")
                    completion(user)
                }
        }
    }
    static func posts(for user: User2, completion: @escaping ([Post2]) -> Void) {
        let docRef = Firestore.firestore().collection("users").document(user.uid).collection("posts")
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let posts = querySnapshot!.documents.flatMap({Post2(dictionary: $0.data())})
                completion(posts)
            }
        }
    }
    
    static func tags(for user: User2, completion: @escaping ([Tag2]) -> Void){
        let docRef = Firestore.firestore().collection("users").document(user.uid).collection("tags")
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let tags = querySnapshot!.documents.flatMap({Tag2(dictionary: $0.data())})
                completion(tags)
            }
        }
    }
}
