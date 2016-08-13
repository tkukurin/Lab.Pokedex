import UIKit

class AnimationUtils {
    
    static func shakeFieldAnimation(txtField: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(txtField.center.x - 8, txtField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(txtField.center.x + 8, txtField.center.y))
        txtField.layer.addAnimation(animation, forKey: "position")
    }
    
}
