//
//  CustomBlurEffect.swift
//  CustomBlurEffectView
//
//  Created by Kononec Dmitrii on 07.09.2020.
//

import UIKit

@available(iOS 8.0, *)
class CustomBlurEffect: UIBlurEffect {
    
    public var blurRadius: CGFloat = 10.0
    
    private enum Constants {
        static let blurRadiusSettingKey = "blurRadius"
    }
    
    @available(iOS 14.0, *)
    class func effect(with style: UIBlurEffect.Style) -> CustomBlurEffect {
        // Create private blur effect at runtime instead of calling super.init
        let baseEffect: UIBlurEffect
        if let blurClass = NSClassFromString("_UICustomBlurEffect") as? UIBlurEffect.Type {
            baseEffect = blurClass.init()
            baseEffect.setValue(style.rawValue, forKey: "style") // optional
        } else {
            // fallback: create a regular UIBlurEffect (avoids super.init crash)
            baseEffect = UIBlurEffect(style: style)
        }

        // Set the class to self
        object_setClass(baseEffect, self)

        guard let effect = baseEffect as? CustomBlurEffect else {
            fatalError("Failed to cast to CustomBlurEffect")
        }
        return effect
    }

    
    override func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone)
        object_setClass(result, Self.self)
        return result
    }
    
    override var effectSettings: AnyObject {
        get {
            let settings = super.effectSettings
            settings.setValue(blurRadius, forKey: Constants.blurRadiusSettingKey)
            return settings
        }
        set {
            super.effectSettings = newValue
        }
    }
    
}
