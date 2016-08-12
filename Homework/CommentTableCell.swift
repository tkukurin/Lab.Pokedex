//
//  CommentTableCell.swift
//  Homework
//
//  Created by toni-user on 12/08/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import UIKit

class CommentTableCell: UITableViewCell {
    
    @IBOutlet weak var commenterUsernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    func setComment(username: String, comment: Comment) {
        commenterUsernameLabel.text = username
        dateLabel.text = String(comment.attributes?.createdAt)
        commentLabel.text = comment.attributes?.content
    }
    
}
