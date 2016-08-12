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
    
    override func awakeFromNib() {
        serverRequestor = Container.sharedInstance.getServerRequestor()
    }
    
    @IBAction func didTapSendButton(sender: AnyObject) {
        guard let commentText: String = self.textField.text else {
            ProgressHud.indicateFailure("Pls enter comment")
            return
        }
        
        serverRequestor.doMultipart(RequestEndpoint.forComments(pokemonId),
                                    user: user,
                                    attributes: ["content":commentText],
                                    callback: serverActionCallback)
    }
    
    func serverActionCallback(response: ServerResponse<String>?) {
        guard let response: ServerResponse<String> = response else {
            ProgressHud.indicateFailure("Bad server response.")
            return
        }
        
        response
            .ifSuccessfulDo({  self.commentCreatedCallback(try Unbox($0)) })
            .ifFailedDo({ _ in ProgressHud.indicateFailure("Couldn't parse server response.") })
        
    }
    
    func commentCreatedCallback(comment: Comment) {
        print("Created comment \(comment)")
    }

    
}
