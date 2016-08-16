import UIKit

//
// Easy means of instantiation from a view controller.
// The idea is to use one-to-one correspondency between Storyboard ID and class name.
// Then simple instantiation can be done by converting a Type to string.
//

extension UIViewController {
    
    func instantiate<T: UIViewController>(name: String, injecting: T -> () = { obj in }) -> T {
        let instantiatedObj = self.storyboard?.instantiateViewControllerWithIdentifier(name) as! T
        injecting(instantiatedObj)
        
        return instantiatedObj
    }
    
    func instantiate<T: UIViewController>(type: T.Type, injecting: T -> () = { obj in }) -> T {
        let instantiatedObj = self.storyboard?.instantiateViewControllerWithIdentifier(String(type)) as! T
        injecting(instantiatedObj)
        
        return instantiatedObj
    }
    
    func pushController<T: UIViewController>(name: String, injecting: T -> () = { obj in }) {
        let controller = instantiate(name, injecting: injecting)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pushController<T: UIViewController>(type: T.Type, injecting: T -> () = { obj in }) {
        let controller = instantiate(type, injecting: injecting)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}