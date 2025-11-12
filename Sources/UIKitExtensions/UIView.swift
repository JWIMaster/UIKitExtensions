import UIKit
import UIKitCompatKit

extension UIView {
    public func pinToEdges(of view: UIView, insetBy insets: UIEdgeInsets = .zero) {
        guard let parent = superview else {
            return
        }
        
        let constraints = [
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    public func pinToCenter(of view: UIView, offsetBy offset: (x: CGFloat, y: CGFloat) = (x: 0, y: 0)) {
        let constraints = [
            centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.x),
            centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.y)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}


public extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc
            }
            responder = r.next
        }
        return nil
    }
}

public extension UIView {
    enum SlideDirection {
        case left
        case right
    }
    
    class func transition(from oldView: UIView?, to newView: UIView, direction: SlideDirection, in container: UIView, animated: Bool = true, completionHandler: @escaping () -> ()) {
        guard newView !== oldView else { return }
        
        oldView?.isHidden = false
        newView.isHidden = false
        
        let width = container.bounds.width
        let newOffset = direction == .left ? width : -width
        let oldOffset = direction == .left ? -width : width

        // Immediately set starting positions without jumping
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        newView.layer.transform = CATransform3DMakeTranslation(newOffset, 0, 0)
        newView.layer.opacity = 0
        oldView?.layer.transform = CATransform3DIdentity
        oldView?.layer.opacity = 1
        CATransaction.commit()
        
        let animations = {
            // Animate transform
            let transformAnimOld = CABasicAnimation(keyPath: "transform.translation.x")
            transformAnimOld.fromValue = 0
            transformAnimOld.toValue = oldOffset
            transformAnimOld.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transformAnimOld.duration = 0.35
            oldView?.layer.add(transformAnimOld, forKey: "slideOut")
            oldView?.layer.transform = CATransform3DMakeTranslation(oldOffset, 0, 0)
            
            let transformAnimNew = CABasicAnimation(keyPath: "transform.translation.x")
            transformAnimNew.fromValue = newOffset
            transformAnimNew.toValue = 0
            transformAnimNew.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transformAnimNew.duration = 0.35
            newView.layer.add(transformAnimNew, forKey: "slideIn")
            newView.layer.transform = CATransform3DIdentity
            
            // Animate opacity
            let opacityAnimOld = CABasicAnimation(keyPath: "opacity")
            opacityAnimOld.fromValue = 1
            opacityAnimOld.toValue = 0
            opacityAnimOld.duration = 0.35
            oldView?.layer.add(opacityAnimOld, forKey: "fadeOut")
            oldView?.layer.opacity = 0
            
            let opacityAnimNew = CABasicAnimation(keyPath: "opacity")
            opacityAnimNew.fromValue = 0
            opacityAnimNew.toValue = 1
            opacityAnimNew.duration = 0.35
            newView.layer.add(opacityAnimNew, forKey: "fadeIn")
            newView.layer.opacity = 1
        }
        
        let completion: () -> Void = {
            oldView?.isHidden = true
            container.bringSubviewToFront(newView)
            completionHandler()
        }
        
        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.35)
            CATransaction.setCompletionBlock(completion)
            animations()
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            animations()
            CATransaction.commit()
            completion()
        }
    }
}





