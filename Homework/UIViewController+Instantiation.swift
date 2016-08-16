import UIKit

extension UIViewController {
    
    func instantiate<T>(name: String, injecting: T -> () = { obj in }) -> T {
        let instantiatedObj = self.storyboard?.instantiateViewControllerWithIdentifier(name) as! T
        injecting(instantiatedObj)
        
        return instantiatedObj
    }
    
    func instantiate<T>(type: T.Type, injecting: T -> () = { obj in }) -> T {
        let instantiatedObj = self.storyboard?.instantiateViewControllerWithIdentifier(String(type)) as! T
        injecting(instantiatedObj)
        
        return instantiatedObj
    }
}