import UIKit
import QuartzCore

@objc public class CAFilterWrapper: NSObject {

    // MARK: - Filter Types
    public enum FilterType: String, CaseIterable {
        case multiplyColor = "multiplyColor"
        case multiplyGradient = "multiplyGradient"
        case gaussianBlur = "gaussianBlur"
        case pageCurl = "pageCurl"
        case fog = "fog"
        case lighting = "lighting"
        case clear = "clear"
        case copy = "copy"
        case sourceOver = "sourceOver"
        case sourceIn = "sourceIn"
        case sourceOut = "sourceOut"
        case sourceAtop = "sourceAtop"
        case destOver = "destOver"
        case destIn = "destIn"
        case destOut = "destOut"
        case destAtop = "destAtop"
        case xor = "xor"
        case plusL = "plusL"
        case multiply = "multiply"
        case lanczos = "lanczos"
        case linear = "linear"
        case nearest = "nearest"
        case trilinear = "trilinear"
    }

    // MARK: - Private filter instance
    private let internalFilter: AnyObject

    // MARK: - Public init
    public init?(type: FilterType) {
        guard let CAFilterClass = NSClassFromString("CAFilter") as? NSObject.Type else {
            return nil
        }

        let sel = NSSelectorFromString("filterWithName:")
        guard CAFilterClass.responds(to: sel),
              let filter = CAFilterClass.perform(sel, with: type.rawValue)?.takeUnretainedValue() else {
            return nil
        }

        self.internalFilter = filter
        super.init()
    }

    // MARK: - Key/Value Access
    public func setValue(_ value: Any, forKey key: String) {
        internalFilter.perform(NSSelectorFromString("setValue:forKey:"), with: value, with: key)
    }

    public override func value(forKey key: String) -> Any? {
        return internalFilter.perform(NSSelectorFromString("valueForKey:"), with: key)?.takeUnretainedValue()
    }

    public func setDefaults() {
        let sel = NSSelectorFromString("setDefaults")
        if internalFilter.responds(to: sel) {
            internalFilter.perform(sel)
        }
    }

    // MARK: - Convenience for Gaussian Blur
    public func setBlurRadius(_ radius: CGFloat) {
        setValue(radius, forKey: "inputRadius")
    }

    public func blurRadius() -> CGFloat {
        return value(forKey: "inputRadius") as? CGFloat ?? 0
    }

    public func setBlurQuality(_ quality: String) {
        setValue(quality, forKey: "inputQuality")
    }

    public func blurQuality() -> String {
        return value(forKey: "inputQuality") as? String ?? "default"
    }

    // MARK: - Apply to layer
    public func apply(to layer: CALayer) {
        // layer.filters expects [Any]
        layer.setValue([internalFilter], forKey: "filters")
    }
}
