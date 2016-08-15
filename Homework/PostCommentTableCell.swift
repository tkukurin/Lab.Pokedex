//
//  PostCommentTableCell.swift
//  Homework
//
//  Created by toni-user on 12/08/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import UIKit
import Unbox
import Alamofire

class PostCommentTableCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    var serverRequestor: ServerRequestor!
    
    var pokemonId: Int!
    var user: User!
    var delegate: CommentCreatedDelegate!
    
    override func awakeFromNib() {
        serverRequestor = Container.sharedInstance.get(ServerRequestor.self)
    }
    
    @IBAction func didTapSendButton(sender: AnyObject) {
        guard let commentText: String = self.textField.text
                where !commentText.isEmpty else {
            ProgressHud.indicateFailure("Please enter a comment before sending")
            return
        }
        
        ApiCommentPostRequest()
            .setSuccessHandler(commentCreatedCallback)
            .setFailureHandler({ ProgressHud.indicateFailure("Bad server response.") })
            .doPostComment(user, pokemonId: pokemonId, content: commentText)
    }
    
    func commentCreatedCallback(commentCreatedResponse: CommentCreatedResponse) {
        self.textField.text = ""
        delegate.notify(commentCreatedResponse.comment)
    }
    
}
