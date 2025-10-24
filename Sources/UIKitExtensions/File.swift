import UIKit
import QuartzCore
import ObjectiveC.runtime

@objc public class CAFilterWrapper: NSObject {

    // MARK: - Filter Types
    @objc public enum FilterType: String, CaseIterable {
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

    // MARK: - Private CAFilter instance
    private let internalFilter: AnyObject

    // MARK: - Public properties
    public var isEnabled: Bool {
        get { internalFilter.value(forKey: "enabled") as? Bool ?? true }
        set { internalFilter.setValue(newValue, forKey: "enabled") }
    }

    public var cachesInputImage: Bool {
        get { internalFilter.value(forKey: "cachesInputImage") as? Bool ?? false }
        set { internalFilter.setValue(newValue, forKey: "cachesInputImage") }
    }

    public var name: String {
        get { internalFilter.value(forKey: "name") as? String ?? "" }
        set { internalFilter.setValue(newValue, forKey: "name") }
    }

    public var type: FilterType? {
        guard let raw = internalFilter.value(forKey: "type") as? String else { return nil }
        return FilterType(rawValue: raw)
    }

    // MARK: - Init with enum
    public init?(type: FilterType) {
        guard
            let CAFilterClass = NSClassFromString("CAFilter") as? NSObject.Type,
            CAFilterClass.responds(to: NSSelectorFromString("filterWithName:"))
        else { return nil }

        let sel = NSSelectorFromString("filterWithName:")
        let unmanaged = CAFilterClass.perform(sel, with: type.rawValue)
        guard let filterInstance = unmanaged?.takeUnretainedValue() else { return nil }

        self.internalFilter = filterInstance
        super.init()
    }

    // MARK: - Key/Value Access
    public func setValue(_ value: Any, forKey key: String) {
        internalFilter.setValue(value, forKey: key)
    }

    public override func value(forKey key: String) -> Any? {
        internalFilter.value(forKey: key)
    }

    public func setDefaults() {
        let selector = NSSelectorFromString("setDefaults")
        if internalFilter.responds(to: selector) {
            internalFilter.perform(selector)
        }
    }

    // MARK: - Convenience for Gaussian Blur
    public func setBlurRadius(_ radius: CGFloat) {
        internalFilter.setValue(radius, forKey: "inputRadius")
    }

    public func blurRadius() -> CGFloat {
        return internalFilter.value(forKey: "inputRadius") as? CGFloat ?? 0
    }

    public func setBlurQuality(_ quality: String) {
        internalFilter.setValue(quality, forKey: "inputQuality")
    }

    public func blurQuality() -> String {
        return internalFilter.value(forKey: "inputQuality") as? String ?? "default"
    }
}
