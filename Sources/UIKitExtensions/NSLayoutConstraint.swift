import UIKit

#if IOS_7
import UIKitCompatKit
#endif

extension UIView {
    public func pinToEdges(of view: UIView, insetBy insets: UIEdgeInsets = .zero) {
        guard let parent = superview else {
            fatalError()
        }
        
        let constraints = [
            topAnchor.constraint(equalTo: parent.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -insets.left)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}



