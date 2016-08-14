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
    static let DATE_FORMATTER = NSDateFormatter()
    
    @IBOutlet weak var commenterUsernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    func setDate(date: NSDate?) {
        CommentTableCell.DATE_FORMATTER.dateFormat = "MMM dd, yyyy"
        
        Result
            .ofNullable(date)
            .map({ CommentTableCell.DATE_FORMATTER.stringFromDate($0) })
            .ifSuccessfulDo({ self.dateLabel.text = $0 })
            .ifFailedDo({ _ in self.dateLabel.hidden = true })
    }
    
}
