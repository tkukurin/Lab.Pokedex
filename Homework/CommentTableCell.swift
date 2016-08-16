
import UIKit
import Foundation

class CommentTableCell: UITableViewCell {
    
    static let DISPLAY_DATE_FORMAT: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        
        return formatter
    }()
    
    @IBOutlet weak var commenterUsernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    func setDate(date: NSDate?) {
        Result
            .ofNullable(date)
            .map({ CommentTableCell.DISPLAY_DATE_FORMAT.stringFromDate($0) })
            .ifPresent({ self.dateLabel.text = $0 })
            .orElseDo({ self.dateLabel.hidden = true })
    }
    
}
