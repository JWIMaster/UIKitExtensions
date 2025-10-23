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

public extension UIColor {
    /// Returns a version of the color with increased saturation
    func withIncreasedSaturation(factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }

        // Multiply the saturation by factor and clamp between 0 and 1
        let newSaturation = min(max(saturation * factor, 0), 1)

        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
}
