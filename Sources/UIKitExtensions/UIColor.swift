//
//  File.swift
//  
//
//  Created by JWI on 15/10/2025.
//

import Foundation
import UIKit

public extension UIColor {
    class var random: UIColor {
        return UIColor.init(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }
    
    class var tealBlue: UIColor {
        return UIColor.init(red: 0, green: 122/255, blue: 250/255, alpha: 1)
    }
}
