//
//  CommentTableCell.swift
//  Homework
//
//  Created by toni-user on 12/08/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import UIKit
import Foundation

class CommentTableCell: UITableViewCell {
    
    @IBOutlet weak var commenterUsernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    func setDate(date: NSDate?) {
        Result
            .ofNullable(date)
            .map({ $0.description })
            //.map({ $0.substringToIndex($0.endIndex.advancedBy(-5)) })
            .ifSuccessfulDo({ self.dateLabel.text = $0 })
            .ifFailedDo({ _ in self.dateLabel.hidden = true })
    }
    
}
