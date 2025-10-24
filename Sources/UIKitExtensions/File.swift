import UIKit
import QuartzCore

@objc public class CAFilterWrapper: NSObject {

    // Swift-only enum
    public enum FilterType: String, CaseIterable {
        case multiplyColor, multiplyGradient, gaussianBlur, pageCurl, fog, lighting, clear, copy
        case sourceOver, sourceIn, sourceOut, sourceAtop, destOver, destIn, destOut, destAtop
        case xor, plusL, multiply, lanczos, linear, nearest, trilinear
    }

    // Private filter instance
    private let internalFilter: AnyObject

    // Init
    public init?(type: FilterType) {
        guard let CAFilterClass = NSClassFromString("CAFilter") as? NSObject.Type else { return nil }
        let sel = NSSelectorFromString("filterWithName:")
        guard CAFilterClass.responds(to: sel),
              let filter = CAFilterClass.perform(sel, with: type.rawValue)?.takeUnretainedValue() else {
            return nil
        }
        self.internalFilter = filter
        super.init()
    }

    // MARK: - Key/Value Access (renamed to avoid NSObject conflict)
    @objc public func setFilterValue(_ value: Any, forKey key: String) {
        (internalFilter as? NSObject)?.setValue(value, forKey: key)
    }

    @objc public func filterValue(forKey key: String) -> Any? {
        return (internalFilter as? NSObject)?.value(forKey: key)
    }

    @objc public func setDefaults() {
        let sel = NSSelectorFromString("setDefaults")
        if internalFilter.responds(to: sel) {
            internalFilter.perform(sel)
        }
    }

    // MARK: - Convenience for Gaussian Blur
    @objc public func setBlurRadius(_ radius: CGFloat) {
        setFilterValue(radius, forKey: "inputRadius")
    }

    @objc public func blurRadius() -> CGFloat {
        return filterValue(forKey: "inputRadius") as? CGFloat ?? 0
    }

    @objc public func setBlurQuality(_ quality: String) {
        setFilterValue(quality, forKey: "inputQuality")
    }

    @objc public func blurQuality() -> String {
        return filterValue(forKey: "inputQuality") as? String ?? "default"
    }

    // MARK: - Apply to layer
    @objc public func apply(to layer: CALayer) {
        layer.setValue([internalFilter], forKey: "filters")
    }
}
