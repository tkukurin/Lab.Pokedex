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
        //hideDateLabelIfNoDatePresent(comment.attributes?.createdAt)
        dateLabel.text = comment.attributes?.createdAt
        commentLabel.text = comment.attributes?.content
    }
    
    func hideDateLabelIfNoDatePresent(date: NSDate?) {
        Result
            .ofNullable(date)
            .map({ String($0) })
            .ifSuccessfulDo({ self.dateLabel.text = $0 })
            .ifFailedDo({ _ in self.dateLabel.hidden = true })
    }
    
}
