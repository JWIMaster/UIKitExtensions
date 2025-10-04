//
//  UIButton.swift
//  
//
//  Created by JWI on 4/10/2025.
//

import Foundation
import UIKit


extension UIButton {
    convenience init(type: UIButton.ButtonType = .system, text: String, font: UIFont = .systemFont(ofSize: 17)) {
        self.init(type: type)
        self.setTitle(text, for: .normal)
        self.titleLabel?.font = font
    }
}


