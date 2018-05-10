//  File.swift
//  SweatNet
//
//  Created by Alex on 4/5/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import AVFoundation
import SearchTextField

class CreatePostViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var postThumbnail: UIImageView!
    @IBOutlet weak var addNotesTextView: UITextView!
    @IBOutlet weak var mySearchTextField: SearchTextField!
    
    var thumbnailImage: UIImage?
    var screenshotOut: UIImage?
    var videoURL: URL?
    var tags = [Tag2]()
    var selectedTagID: String?
    var selectedTagTitle: String?
    var filter_items = [SearchTextFieldItem]()
    var post: Post2?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserService2.tags(for: User2.current) { (tags) in
            for tag in tags{
                self.filter_items.append(SearchTextFieldItem(title: tag.title, subtitle: tag.id,image: UIImage(named: "Camera")))
            }
            self.mySearchTextField.filterItems(self.filter_items)
        }

        addNotesTextView.delegate = self
        postThumbnail.contentMode = .scaleAspectFit
        postThumbnail.image = thumbnailImage
        addNotesTextView.text = "Notes..."
        addNotesTextView.textColor = UIColor.lightGray
        mySearchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            self.mySearchTextField.text = item.title
            // Do whatever you want with the picked item
            self.selectedTagID = item.subtitle
            self.selectedTagTitle = item.title
            print(self.selectedTagID!)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCamera" {
            //Note uploadThumbnail calls create or update tag as needed with new url. 
            TagService2.uploadThumbnail(title: mySearchTextField.text!, latestThumbnailImage: self.thumbnailImage!)
            
            //Let post service know what tag to add to the post itself.
            let tagTitle = mySearchTextField.text!
            if MyVariables.isScreenshot == true {
                PostService.createImagePost(image: self.screenshotOut!, tagTitle: tagTitle, notes: addNotesTextView.text ?? "")
            } else {
                PostService.createVideoPost(video: self.videoURL!, tagTitle: tagTitle, notes: addNotesTextView.text ?? "")
            }
        }
    }
}
