//
//  StateVariables.swift
//  SweatNet
//
//  Created by Alex on 4/9/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//
import UIKit

struct MyVariables {
    static var isScreenshot = false
    static var selectedCells: [Int:Bool] = [:]
}

final class tagColors {
    static let sharedInstance = tagColors()
    private init() { }
    var dict = [String: UIColor]()
}

final class selectedCells {
    static let sharedInstance = selectedCells()
    private init() {}
    var dict = [IndexPath:Bool]()
}
