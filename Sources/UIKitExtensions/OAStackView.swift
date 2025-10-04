//
//  File.swift
//  
//
//  Created by JWI on 4/10/2025.
//

import Foundation
import OAStackView

extension OAStackView {
    public convenience init(arrangedSubviews: [UIView] = [],
                            axis: NSLayoutConstraint.Axis,
                            alignment: OAStackViewAlignment,
                            distribution: OAStackViewDistribution,
                            spacing: CGFloat = 0,
                            useAutoResizingMask: Bool = true
    ) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.translatesAutoresizingMaskIntoConstraints = useAutoResizingMask
    }
    
    public func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
    
}
