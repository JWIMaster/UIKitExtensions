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



