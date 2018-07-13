//
//  UserDefaultsHelper.swift
//  SweatNet
//
//  Created by Alex on 7/10/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}
