//
//  BytesFormatter.swift
//  SweatNet
//
//  Created by Alex on 7/11/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import Foundation

func format(bytes: Double) -> String {
    guard bytes > 0 else {
        return "0 bytes"
    }
    
    // Adapted from http://stackoverflow.com/a/18650828
    let suffixes = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
    let k: Double = 1000
    let i = floor(log(bytes) / log(k))
    
    // Format number with thousands separator and everything below 1 GB with no decimal places.
    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = i < 3 ? 0 : 1
    numberFormatter.numberStyle = .decimal
    
    let numberString = numberFormatter.string(from: NSNumber(value: bytes / pow(k, i))) ?? "Unknown"
    let suffix = suffixes[Int(i)]
    return "\(numberString) \(suffix)"
}
