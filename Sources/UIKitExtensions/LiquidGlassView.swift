import UIKit
import LiveFrost
import FoundationCompatKit

/// Optimised LiquidGlassView
/// Single file replacement that focuses on reuse of sublayers, background rendering,
/// correct caching, and minimal main thread work
public final class LiquidGlassView: UIView {

    // MARK: - Configurable properties
    public var cornerRadius: CGFloat = 50 { didSet { updateCornersAndShadow(); updateLayerCorners() } }
    public var shadowOpacity: Float = 0.6 { didSet { updateShadowOnly() } }
    public var shadowRadius: CGFloat = 12 { didSet { updateShadowOnly() } }
    public var shadowColor: CGColor = UIColor.black.cgColor { didSet { updateShadowOnly() } }
    public var shadowOffset: CGSize = .zero { didSet { updateShadowOnly() } }
    public var saturationBoost: CGFloat = 1.1 { didSet { markDecorDirty() } }

    public var blurRadius: CGFloat = 12 {
        didSet {
            if let lf = blurView as? LFGlassView { lf.blurRadius = blurRadius }
            else if #available(iOS 14.0, *), let v = blurView as? VisualEffectView { v.blurRadius = blurRadius }
            else if #available(iOS 9.0, *), let v = blurView as? VisualEffectView1 { v.blurRadius = blurRadius }
        }
    }

    public var scaleFactor: CGFloat = 0.4 {
        didSet { if let lf = blurView as? LFGlassView { lf.scaleFactor = scaleFactor } }
    }

    public var frameInterval: Int = 3 {
        didSet { if let lf = blurView as? LFGlassView { lf.frameInterval = UInt(frameInterval) } }
    }

    public var isLiveBlurring: Bool = true {
        didSet { if let lf = blurView as? LFGlassView { lf.isLiveBlurring = isLiveBlurring } }
    }

    public weak var snapshotTargetView: UIView? {
        didSet { if let lf = blurView as? LFGlassView { lf.snapshotTargetView = snapshotTargetView } }
    }

    public var tintColorForGlass: UIColor = UIColor.blue.withAlphaComponent(0.05) { didSet { markDecorDirty() } }
    public var tintGradientColors: [UIColor]? { didSet { markDecorDirty() } }

    public enum AdvancedFilterOptions: String, CaseIterable {
        case tint, darken, highlight, depth, rim, innerShadow
    }

    public var filterExclusions: [AdvancedFilterOptions]
    public var solidViewColour: UIColor = .clear { didSet { solidView?.backgroundColor = solidViewColour } }
    public var disableBlur: Bool = false { didSet { configureBlurModeIfNeeded() } }

    // MARK: - Subviews and layers
    public var blurView: UIView?
    public var solidView: UIView?

    private let decorLayer = CALayer()

    private let tintLayer = CAGradientLayer()
    private let darkenLayer = CAGradientLayer()
    private let highlightLayer = CAGradientLayer()
    private let depthLayer = CAGradientLayer()
    private let rimLayer = CALayer()
    private let innerShadowLayer = CALayer()

    private var didSetupStaticLayers = false

    private static let renderQueue = DispatchQueue(label: "com.yourapp.liquidglass.render", attributes: .concurrent, target: .global(qos: .userInitiated))
    private var renderCache: NSCache<NSString, CGImage> { LiquidGlassCache.shared.cache }

    private var lastRenderedSize: CGSize = .zero
    private var lastCacheKey: NSString?
    private var decorDirty = true

    // MARK: - Init
    public init(
        blurRadius: CGFloat = 12,
        cornerRadius: CGFloat = 50,
        snapshotTargetView: UIView?,
        disableBlur: Bool = false,
        filterExclusions: [AdvancedFilterOptions] = []
    ) {
        self.filterExclusions = filterExclusions
        super.init(frame: .zero)
        self.cornerRadius = cornerRadius
        self.blurRadius = blurRadius
        self.snapshotTargetView = snapshotTargetView
        self.disableBlur = disableBlur

        configureBlurModeIfNeeded()
        commonInit()
    }

    public convenience init(
        blurRadius: CGFloat = 12,
        cornerRadius: CGFloat = 50,
        snapshotTargetView: UIView?
    ) {
        self.init(blurRadius: blurRadius, cornerRadius: cornerRadius, snapshotTargetView: snapshotTargetView, disableBlur: false, filterExclusions: [])
    }

    required init?(coder: NSCoder) {
        self.filterExclusions = []
        super.init(coder: coder)
        configureBlurModeIfNeeded()
        commonInit()
    }

    private func configureBlurModeIfNeeded() {
        if disableBlur {
            if solidView == nil { solidView = UIView() }
            solidView?.backgroundColor = solidViewColour
            blurView?.removeFromSuperview()
            blurView = nil
        } else {
            // prefer platform specific visual effect views if available
            if #available(iOS 14.0, *), blurView == nil {
                let blur = VisualEffectView()
                blur.colorTint = .clear
                blur.blurRadius = blurRadius
                blurView = blur
            } else if #available(iOS 9.0, *), blurView == nil {
                let blur = VisualEffectView1()
                blur.blurRadius = blurRadius
                blurView = blur
            } else if blurView == nil {
                let blur = LFGlassView()
                blur.snapshotTargetView = snapshotTargetView
                blur.blurRadius = blurRadius
                blurView = blur
            }
            solidView?.removeFromSuperview()
            solidView = nil
        }
    }

    private func commonInit() {
        clipsToBounds = true
        layer.masksToBounds = false

        setupStaticLayersIfNeeded()
        if let blurView = blurView as? LFGlassView {
            blurView.isLiveBlurring = true
        }

        if let blurView = blurView {
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.masksToBounds = true
            addSubview(blurView)
            sendSubviewToBack(blurView)
        } else if let solidView = solidView {
            solidView.layer.cornerRadius = cornerRadius
            solidView.layer.masksToBounds = true
            addSubview(solidView)
        }

        decorLayer.masksToBounds = true
        layer.addSublayer(decorLayer)

        markDecorDirty()
    }

    // MARK: - Static layers setup
    private func setupStaticLayersIfNeeded() {
        guard !didSetupStaticLayers else { return }
        didSetupStaticLayers = true

        tintLayer.compositingFilter = "softLightBlendMode"
        darkenLayer.compositingFilter = "multiplyBlendMode"
        highlightLayer.compositingFilter = "screenBlendMode"
        depthLayer.compositingFilter = "softLightBlendMode"

        rimLayer.borderWidth = 0.8
        rimLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        innerShadowLayer.contentsGravity = .resizeAspectFill
        innerShadowLayer.masksToBounds = true

        decorLayer.addSublayer(tintLayer)
        decorLayer.addSublayer(darkenLayer)
        decorLayer.addSublayer(highlightLayer)
        decorLayer.addSublayer(depthLayer)
        decorLayer.addSublayer(rimLayer)
        decorLayer.addSublayer(innerShadowLayer)
    }

    // MARK: - Lifecycle
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            markDecorDirty()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        blurView?.frame = bounds
        solidView?.frame = bounds
        decorLayer.frame = bounds

        updateLayerCorners()
        updateShadowOnly()

        if bounds.size != lastRenderedSize {
            lastRenderedSize = bounds.size
            markDecorDirty()
        }

        if decorDirty {
            renderDecorLayerAsync()
        }
    }
    
    private func updateCornersAndShadow() {
        self.updateShadowOnly()
        self.updateLayerCorners()
    }

    private func updateLayerCorners() {
        decorLayer.cornerRadius = cornerRadius
        tintLayer.cornerRadius = cornerRadius
        darkenLayer.cornerRadius = cornerRadius
        highlightLayer.cornerRadius = cornerRadius
        depthLayer.cornerRadius = cornerRadius
        rimLayer.cornerRadius = cornerRadius
        innerShadowLayer.cornerRadius = cornerRadius

        blurView?.layer.cornerRadius = cornerRadius
        solidView?.layer.cornerRadius = cornerRadius
    }

    private func updateShadowOnly() {
        layer.shadowColor = shadowColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius * 0.85).cgPath
    }

    // MARK: - Dirty tracking and cache key
    private func markDecorDirty() {
        decorDirty = true
        setNeedsLayout()
    }

    private func currentDecorCacheKey() -> NSString? {
        guard bounds.width > 0, bounds.height > 0 else { return nil }
        let scale = UIScreen.main.scale
        let w = Int(bounds.width * scale)
        let h = Int(bounds.height * scale)

        let coloursKey: String
        if let colors = tintGradientColors, !colors.isEmpty {
            coloursKey = colors.map { String($0.hexValue) }.joined(separator: "_")
        } else {
            coloursKey = String(tintColorForGlass.hexValue)
        }

        let filters = filterExclusions.map { $0.rawValue }.joined(separator: "_")

        let key = "\(w)x\(h)_r\(Int(cornerRadius))_c\(coloursKey)_sat\(String(format: "%.2f", saturationBoost))_f\(filters)"
        return NSString(string: key)
    }

    // MARK: - Async rendering
    private func renderDecorLayerAsync() {
        guard let key = currentDecorCacheKey() else { decorDirty = false; return }
        lastCacheKey = key

        if let cached = renderCache.object(forKey: key) {
            decorLayer.contents = cached
            decorDirty = false
            return
        }

        decorDirty = false

        // Capture parameters to avoid races
        let size = bounds.size
        let cornerRadius = self.cornerRadius
        let tintColors = tintGradientColors
        let tint = tintColorForGlass
        let saturation = saturationBoost
        let exclusions = Set(filterExclusions)

        LiquidGlassView.renderQueue.async { [weak self] in
            guard let self = self else { return }
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            guard let ctx = UIGraphicsGetCurrentContext() else {
                UIGraphicsEndImageContext()
                return
            }

            // Create a temporary layer tree purely for rendering into context
            let container = CALayer()
            container.frame = CGRect(origin: .zero, size: size)

            if !exclusions.contains(.tint) {
                let g = CAGradientLayer()
                g.frame = container.bounds
                g.cornerRadius = cornerRadius
                g.masksToBounds = true
                g.compositingFilter = "softLightBlendMode"
                if let colours = tintColors, !colours.isEmpty {
                    g.colors = colours.map { $0.withIncreasedSaturation(factor: saturation).cgColor }
                    g.startPoint = CGPoint(x: 0.5, y: 0)
                    g.endPoint = CGPoint(x: 0.5, y: 1)
                } else {
                    g.backgroundColor = tint.withIncreasedSaturation(factor: saturation).cgColor
                }
                container.addSublayer(g)
            }

            if !exclusions.contains(.darken) {
                let g = CAGradientLayer()
                g.frame = container.bounds
                g.cornerRadius = cornerRadius
                g.compositingFilter = "multiplyBlendMode"
                g.colors = [UIColor.black.withAlphaComponent(0.22).cgColor, UIColor.clear.cgColor]
                g.startPoint = CGPoint(x: 0.5, y: 1)
                g.endPoint = CGPoint(x: 0.5, y: 0)
                container.addSublayer(g)
            }

            if !exclusions.contains(.highlight) {
                let g = CAGradientLayer()
                g.frame = container.bounds
                g.cornerRadius = cornerRadius
                g.compositingFilter = "screenBlendMode"
                g.colors = [
                    UIColor.white.withAlphaComponent(0.25).cgColor,
                    UIColor.clear.cgColor,
                    UIColor.white.withAlphaComponent(0.2).cgColor,
                    UIColor.white.withAlphaComponent(0.1).cgColor
                ]
                g.locations = [0.0, 0.25, 0.9, 1.0]
                g.startPoint = CGPoint(x: 0, y: 0)
                g.endPoint = CGPoint(x: 1, y: 1)
                container.addSublayer(g)
            }

            if !exclusions.contains(.depth) {
                let g = CAGradientLayer()
                g.frame = container.bounds
                g.cornerRadius = cornerRadius
                g.compositingFilter = "softLightBlendMode"
                g.colors = [
                    UIColor.black.withAlphaComponent(0.15).cgColor,
                    UIColor.clear.cgColor,
                    UIColor.white.withAlphaComponent(0.05).cgColor
                ]
                g.locations = [0.0, 0.6, 1.0]
                g.startPoint = CGPoint(x: 0.5, y: 1)
                g.endPoint = CGPoint(x: 0.5, y: 0)
                container.addSublayer(g)
            }

            if !exclusions.contains(.rim) {
                let rim = CALayer()
                rim.frame = container.bounds
                rim.cornerRadius = cornerRadius
                rim.borderWidth = 0.8
                rim.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
                container.addSublayer(rim)
            }

            if !exclusions.contains(.innerShadow) {
                // inner shadow can be precomputed per size and radius
                let innerKey = "innerShadow_\(Int(size.width))x\(Int(size.height))_\(Int(cornerRadius))" as NSString
                if let cachedShadow = self.renderCache.object(forKey: innerKey) {
                    let shadowLayer = CALayer()
                    shadowLayer.frame = container.bounds
                    shadowLayer.contents = cachedShadow
                    container.addSublayer(shadowLayer)
                } else {
                    UIGraphicsBeginImageContextWithOptions(container.bounds.size, false, UIScreen.main.scale)
                    if let ctxt = UIGraphicsGetCurrentContext() {
                        let path = UIBezierPath(roundedRect: container.bounds, cornerRadius: cornerRadius * 0.85)
                        // draw inner shadow here
                        ctxt.saveGState()
                        ctxt.addPath(path.cgPath)
                        ctxt.clip()

                        let cgShadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
                        let opaqueShadowColor = cgShadowColor.copy(alpha: 1.0)

                        ctxt.setAlpha(cgShadowColor.alpha)
                        ctxt.beginTransparencyLayer(auxiliaryInfo: nil)
                        ctxt.setShadow(offset: CGSize(width: 0, height: 2), blur: 6, color: opaqueShadowColor)
                        ctxt.setBlendMode(.sourceOut)
                        ctxt.setFillColor(opaqueShadowColor ?? UIColor.black.cgColor)
                        ctxt.addPath(path.cgPath)
                        ctxt.fillPath()
                        ctxt.endTransparencyLayer()
                        ctxt.restoreGState()

                        if let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
                            self.renderCache.setObject(image, forKey: innerKey)
                            let shadowLayer = CALayer()
                            shadowLayer.frame = container.bounds
                            shadowLayer.contents = image
                            container.addSublayer(shadowLayer)
                        }
                    }
                    UIGraphicsEndImageContext()
                }
            }

            // Render container into context
            container.render(in: ctx)
            guard let renderedImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
                UIGraphicsEndImageContext()
                return
            }
            UIGraphicsEndImageContext()

            // Cache and update main thread
            self.renderCache.setObject(renderedImage, forKey: key)
            DispatchQueue.main.async {
                // Confirm bounds and key still match
                if self.lastCacheKey == key {
                    self.decorLayer.contents = renderedImage
                }
            }
        }
    }

    // MARK: - Public helpers
    private func markNeedsFullRedraw() {
        // call when parameters that affect drawing change
        markDecorDirty()
        if let key = lastCacheKey { renderCache.removeObject(forKey: key) }
    }

    private func applySaturationBoost() {
        // kept for compatibility
        markDecorDirty()
    }
}

// MARK: - Cache
fileprivate extension UIColor {
    var hexValue: UInt32 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = UInt32(r * 255) << 24
        let gi = UInt32(g * 255) << 16
        let bi = UInt32(b * 255) << 8
        let ai = UInt32(a * 255)
        return ri | gi | bi | ai
    }

}

public final class LiquidGlassCache {
    public static let shared = LiquidGlassCache()
    public let cache = NSCache<NSString, CGImage>()

    public init() {
        cache.countLimit = 300
        cache.totalCostLimit = 80_000_000
    }
}
