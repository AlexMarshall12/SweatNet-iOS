//
//  User.swift
//  SweatNet
//
//  Created by Alex on 5/8/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation

import UIKit
import FirebaseDatabase.FIRDataSnapshot


class User: NSObject {
    
    
    // MARK: - Singleton
    
    // 1
    private static var _current: User?
    
    // 2
    static var current: User {
        
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        // 4
        return currentUser
    }
    
    // MARK: - Class Methods
    
    // 5
    static func setCurrent(_ user: User,writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            // 3
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            
            // 4
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        _current = user
    }
    
    // MARK: - Properties
    
    let uid: String
    let username: String
    let storage: UInt64
    
    // MARK: - Init
    
    init(uid: String, username: String, storage: UInt64) {
        self.uid = uid
        self.username = username
        self.storage = storage
        super.init()
    }
    
    init?(dictionary: [String : Any]) {
        guard let username = dictionary["username"] as? String, let uid = dictionary["uid"] as? String, let storage = dictionary["storage"] as? UInt64
            else { return nil }
        self.uid = uid
        self.username = username
        self.storage = storage
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
            else { return nil }
        self.uid = uid
        self.username = username
        self.storage = 0
        super.init()
    }
    var dictValue: [String: Any] {
        return ["uid":uid ,"username": username,"storage":storage]
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
    }
}


