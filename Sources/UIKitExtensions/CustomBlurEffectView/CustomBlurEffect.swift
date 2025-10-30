import UIKit

@available(iOS 8.0, *)
class CustomBlurEffect: UIBlurEffect {
    
    /// Dynamic blur radius
    public var blurRadius: CGFloat {
        get { return _value(forKey: Constants.blurRadiusSettingKey) ?? 10.0 }
        set { _setValue(newValue, forKey: Constants.blurRadiusSettingKey) }
    }
    
    private enum Constants {
        static let blurRadiusSettingKey = "blurRadius"
    }
    
    /// Creates a CustomBlurEffect instance dynamically
    @available(iOS 14.0, *)
    class func effect(with style: UIBlurEffect.Style) -> CustomBlurEffect {
        // Create private blur effect at runtime instead of calling super.init
        let baseEffect: UIBlurEffect
        if let blurClass = NSClassFromString("_UICustomBlurEffect") as? UIBlurEffect.Type {
            baseEffect = blurClass.init()
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

    /// Copy override (keeps class as CustomBlurEffect)
    override func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone)
        object_setClass(result, Self.self)
        return result
    }

    // MARK: - Helpers

    private func _value<T>(forKey key: String) -> T? {
        return (self as AnyObject).value(forKey: key) as? T
    }

    private func _setValue<T>(_ value: T?, forKey key: String) {
        (self as AnyObject).setValue(value, forKey: key)
    }
}
