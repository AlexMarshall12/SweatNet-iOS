//
//  StorageService.swift
//  SweatNet
//
//  Created by Alex on 3/13/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import FirebaseStorage

struct StorageService {
    // provide method for uploading images
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // 1
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // 2
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // 3
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            // 4
            completion(metadata?.downloadURL())
        })
    }
    static func uploadVideo(_ videoURL: NSURL, at reference: StorageReference, completion: @escaping (URL?) -> Void){
        reference.putFile(from: videoURL as URL, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            completion(metadata?.downloadURL())
        })
    }
    static func uploadThumbnail(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void){
        guard let imageData = UIImageJPEGRepresentation(image,0.1) else {
            return completion(nil)
        }
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // 3
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            // 4
            completion(metadata?.downloadURL())
        })
    }
}

