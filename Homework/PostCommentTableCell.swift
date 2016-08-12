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
        serverRequestor.doMultipart(RequestEndpoint.forComments(pokemonId),
                                    user: user,
                                    attributes: JsonMapBuilder.use({
                                builder in
                                builder.addParam("content", self.textField.text ?? "")
                                    .wrapWithKey("attributes")
                                    .wrapWithKey("data") }),
                               callback: multipartEncodedCallback)
    }
    
    func multipartEncodedCallback(encodingResult: MultipartEncodingResult) {
        switch encodingResult {
        case .Success(let upload, _, _): upload.responseString(completionHandler: serverActionCallback)
        default: break
        }
    
        ProgressHud.indicateFailure()
    }
    
    func serverActionCallback(response: Response<String, NSError>) {
        guard let data = response.data else {
            ProgressHud.indicateFailure("Bad server response.")
            return
        }
        
        let commentResponse: Comment? = try? Unbox(data)
        Result.ofNullable(commentResponse)
            .ifSuccessfulDo({ print($0) })
            .ifFailedDo({ _ in ProgressHud.indicateFailure("Couldn't parse server response.") })
    }

    
}
