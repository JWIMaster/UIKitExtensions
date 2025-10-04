import UIKit
import UIKitCompatKit

extension UIView {
    public func pinToEdges(of view: UIView, insetBy insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
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
        return constraints
    }
}

extension UIButton {
    convenience init(type: UIButton.ButtonType = .system, text: String, font: UIFont = .systemFont(ofSize: 17)) {
        self.init(type: type)
        self.setTitle(text, for: .normal)
        self.titleLabel?.font = font
    }
}

