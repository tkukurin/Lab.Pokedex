import UIKit

class AlertUtils {
    static let DEFAULT_ERR_TITLE = "Whoa there!"
    static let DEFAULT_SERVER_ERR_TITLE = "Connection error"
    
    private var parentController : UIViewController
    
    init(_ parentController: UIViewController) {
        self.parentController = parentController
    }
    
    func alert(errorMessage: String, title: String = AlertUtils.DEFAULT_ERR_TITLE) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        
        parentController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertServerError(title: String = AlertUtils.DEFAULT_SERVER_ERR_TITLE) {
        return alert("Something went wrong contacting the server!", title: title)
    }
}