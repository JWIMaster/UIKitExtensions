//
//  UIButton.swift
//  
//
//  Created by JWI on 4/10/2025.
//

import Foundation
import UIKit


extension UIButton {
    public convenience init(type: UIButton.ButtonType = .system,
                            title: String,
                            forState state: UIControl.State = .normal,
                            font: UIFont = .systemFont(ofSize: 17),
                            titleColor: UIColor = .systemBlue,
                            useAutoResizingMask: Bool = true
    ) {
        self.init(type: type)
        
        self.setTitle(title, for: state)
        
        self.titleLabel?.font = font
        
        self.setTitleColor(titleColor, for: .normal)
        
        self.translatesAutoresizingMaskIntoConstraints = useAutoResizingMask
    }
    
    
    public convenience init(type: UIButton.ButtonType = .system,
                            titleForState: [String: UIControl.State],
                            font: UIFont = .systemFont(ofSize: 17),
                            titleColorForState: [UIColor: UIControl.State],
                            useAutoResizingMask: Bool = false
    ) {
        self.init(type: type)
        
        for (title, state) in titleForState {
            self.setTitle(title, for: state)
        }
        
        self.titleLabel?.font = font
        
        for (titleColor, state) in titleColorForState {
            self.setTitleColor(titleColor, for: state)
        }
        
        self.translatesAutoresizingMaskIntoConstraints = useAutoResizingMask
    }
}

