import Foundation
import QuartzCore
import ObjectiveC.runtime

@objc public class CAFilter: NSObject {
    
    private let internalFilter: AnyObject

    public var name: String {
        get { internalFilter.value(forKey: "name") as? String ?? "" }
        set { internalFilter.setValue(newValue, forKey: "name") }
    }

    public var isEnabled: Bool {
        get { internalFilter.value(forKey: "enabled") as? Bool ?? true }
        set { internalFilter.setValue(newValue, forKey: "enabled") }
    }

    public var cachesInputImage: Bool {
        get { internalFilter.value(forKey: "cachesInputImage") as? Bool ?? false }
        set { internalFilter.setValue(newValue, forKey: "cachesInputImage") }
    }

    public var type: String {
        return internalFilter.value(forKey: "type") as? String ?? ""
    }

    public init?(type: String) {
        guard let filterClass = NSClassFromString("CAFilter") as? NSObject.Type else {
            return nil
        }

        // call +filterWithType: selector
        let selector = NSSelectorFromString("filterWithType:")
        guard filterClass.responds(to: selector) else { return nil }

        let unmanaged = filterClass.perform(selector, with: type)
        guard let filterInstance = unmanaged?.takeUnretainedValue() else { return nil }

        self.internalFilter = filterInstance
        super.init()
    }

    public init?(name: String) {
        guard let filterClass = NSClassFromString("CAFilter") as? NSObject.Type else {
            return nil
        }

        let selector = NSSelectorFromString("filterWithName:")
        guard filterClass.responds(to: selector) else { return nil }

        let unmanaged = filterClass.perform(selector, with: name)
        guard let filterInstance = unmanaged?.takeUnretainedValue() else { return nil }

        self.internalFilter = filterInstance
        super.init()
    }

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
}
