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
    @IBOutlet weak var tagsView: KSTokenView!

    var thumbnailImage: UIImage?
    var postDate: Date?
    var screenshotOut: UIImage?
    var videoURL: URL?
    var tags = [Tag]()
    var selectedTagID: String?
    var selectedTagTitle: String?
    var filter_items = [SearchTextFieldItem]()
    var post: Post?
    var autocompleteUrls = [String]()
    let names: Array<String> = ["apple","banana"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserService.tags(for: User.current) { (tags) in
            self.tags = tags
            for tag in tags{
                self.filter_items.append(SearchTextFieldItem(title: tag.title, subtitle: tag.id,image: UIImage(named: "Camera")))
            }
            //self.mySearchTextField.filterItems(self.filter_items)
        }
        addNotesTextView.delegate = self
        addNotesTextView.textColor = UIColor.lightGray
        addNotesTextView.text = "Notes..."
        tagsView.delegate = self
        tagsView.promptText = "Tags: "
        tagsView.maxTokenLimit = 5 //default is -1 for unlimited number of tokens
        tagsView.style = .squared
        tagsView.searchResultHeight = 200
        tagsView.removesTokensOnEndEditing = false
        postThumbnail.contentMode = .scaleAspectFit
        postThumbnail.image = thumbnailImage
        addNotesTextView.text = "Notes..."
//        mySearchTextField.itemSelectionHandler = { filteredResults, itemPosition in
//            // Just in case you need the item position
//            let item = filteredResults[itemPosition]
//            print("Item at position \(itemPosition): \(item.title)")
//            self.mySearchTextField.text = item.title
//            // Do whatever you want with the picked item
//            self.selectedTagID = item.subtitle
//            self.selectedTagTitle = item.title
//        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Notes"
            textView.textColor = UIColor.lightGray
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCamera" {

            //Let post service know what tag to add to the post itself.
            //let tagTitle = mySearchTextField.text!
            let tokens = self.tagsView.tokens()
            let tokensArr = tokens!.map({
                (token: KSToken) -> String in
                return token.title
            })
            if MyVariables.isScreenshot == true {
                PostService.createImagePost(image: self.screenshotOut!, timeStamp: self.postDate!, tags: tokensArr, notes: addNotesTextView.text ?? "")
            } else {
                PostService.createVideoPost(video: self.videoURL!, timeStamp: self.postDate!, thumbnailImage: self.thumbnailImage!, tags: tokensArr, notes: addNotesTextView.text ?? "")
            }
        }
    }
}

extension CreatePostViewController: KSTokenViewDelegate {
    func tokenView(_ tokenView: KSTokenView, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?) {
        if (string.isEmpty){
            completion!(tags as Array<AnyObject>)
            return
        }
        let filteredTags = self.tags.filter { $0.title.localizedCaseInsensitiveContains(string) }
        completion!(filteredTags as Array<AnyObject>)
    }
    
    func tokenView(_ tokenView: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        let tag = object as! Tag
        return tag.title
    }
    
    func tokenView(_ tokenView: KSTokenView, shouldAddToken token: KSToken) -> Bool {
        
        // Restrict adding token based on token text
        if token.title == "f" {
            return false
        }
        
        // If user input something, it can be checked
        //        print(tokenView.text)
        
        return true
    }
}
