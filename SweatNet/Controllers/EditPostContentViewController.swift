//
//  EditPostContentViewController.swift
//  SweatNet
//
//  Created by Alex on 6/29/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit

struct EditPostAttributes {
    let postId: String?
    let postDate: Date?
    let notes: String?
    let tags: [String:UIColor]?
}

class EditPostContentViewController: UIViewController {
    
    @IBOutlet weak var tokenView: KSTokenView!
    @IBOutlet weak var notesView: UITextView!
    
    var postAttrs: EditPostAttributes?
    var tags = [Tag]()
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let tokens = tokenView.tokens()
        let tagsArr = tokens!.map({
            (token: KSToken) -> String in
            return token.title
        })
        PostService.updatePostContent(id: (postAttrs?.postId)!, notes: notesView.text, tags: tagsArr, postDate: (postAttrs?.postDate)!)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserService.tags(for: User.current) { (tags) in
            self.tags = tags
        }
        tokenView.delegate = self
        tokenView.promptText = "Tags: "
        for (tag,color) in (postAttrs?.tags)! {
            let token = KSToken(title: tag)
            token.tokenBackgroundColor = color
            tokenView.addToken(token)
        }
        notesView.text = postAttrs?.notes
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension EditPostContentViewController: KSTokenViewDelegate {
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

