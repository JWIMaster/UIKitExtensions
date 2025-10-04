//
//  File.swift
//  
//
//  Created by JWI on 4/10/2025.
//

import Foundation
import UIKit

@available(iOS 9.0, *)
extension UIStackView {
    public convenience init(arrangedSubviews: [UIView] = [],
                            axis: NSLayoutConstraint.Axis,
                            alignment: UIStackView.Alignment,
                            distribution: UIStackView.Distribution,
                            spacing: CGFloat = 0
    ) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
    }
    
    public func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
    
}
