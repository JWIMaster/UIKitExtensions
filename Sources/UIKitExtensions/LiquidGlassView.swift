import UIKit
import LiveFrost
import FoundationCompatKit

public class LiquidGlassView: UIView {

    // MARK: - Configurable properties
    public var cornerRadius: CGFloat = 50 {
        didSet { updateCornersAndShadow() }
    }
    public var shadowOpacity: Float = 0.6 { didSet { updateCornersAndShadow() } }
    public var shadowRadius: CGFloat = 12 { didSet { updateCornersAndShadow() } }
    public var shadowColor: CGColor = UIColor.black.cgColor { didSet { updateCornersAndShadow() } }
    public var shadowOffset: CGSize = .zero { didSet { updateCornersAndShadow() } }
    public var saturationBoost: CGFloat = 1.1 { didSet { updateGradientLayers() } }
    public var blurRadius: CGFloat = 12 {
        didSet {
            if let blurView = self.blurView as? LFGlassView { blurView.blurRadius = blurRadius }
            else if #available(iOS 14.0, *), let blurView = self.blurView as? VisualEffectView { blurView.blurRadius = blurRadius }
            else if #available(iOS 9.0, *), let blurView = self.blurView as? VisualEffectView1 { blurView.blurRadius = blurRadius }
        }
    }
    public var scaleFactor: CGFloat = 0.4 { didSet { (blurView as? LFGlassView)?.scaleFactor = scaleFactor } }
    public var frameInterval: Int = 3 { didSet { (blurView as? LFGlassView)?.frameInterval = UInt(frameInterval) } }
    public var isLiveBlurring: Bool = true { didSet { (blurView as? LFGlassView)?.isLiveBlurring = isLiveBlurring } }
    public weak var snapshotTargetView: UIView? { didSet { (blurView as? LFGlassView)?.snapshotTargetView = snapshotTargetView } }
    public var tintColorForGlass: UIColor = UIColor.blue.withAlphaComponent(0.05) { didSet { updateGradientLayers() } }
    public var tintGradientColors: [UIColor]? { didSet { updateGradientLayers() } }
    public var filterExclusions: [AdvancedFilterOptions] = []

    public enum AdvancedFilterOptions: String, CaseIterable {
        case tint, darken, highlight, depth, rim, innerShadow
    }

    public var solidViewColour: UIColor = .clear { didSet { solidView?.backgroundColor = solidViewColour } }
    public var disableBlur: Bool = false { didSet { updateBlur() } }

    // MARK: - Subviews
    public var blurView: UIView?
    public var solidView: UIView?

    // Dynamic layers
    private let tintLayer = CAGradientLayer()
    private let darkenLayer = CAGradientLayer()
    private let highlightLayer = CAGradientLayer()
    private let depthLayer = CAGradientLayer()
    private let rimLayer = CALayer()
    private let innerShadowLayer = CALayer()

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
        setupBlurOrSolidView()
        setupLayers()
        updateCornersAndShadow()
        updateGradientLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBlurOrSolidView()
        setupLayers()
        updateCornersAndShadow()
        updateGradientLayers()
    }

    // MARK: - Setup
    private func setupBlurOrSolidView() {
        if disableBlur {
            solidView = UIView()
            solidView?.backgroundColor = solidViewColour
            addSubview(solidView!)
        } else {
            if #available(iOS 14.0, *) {
                let blur = VisualEffectView()
                blur.blurRadius = blurRadius
                blurView = blur
            } else if #available(iOS 9.0, *) {
                let blur = VisualEffectView1()
                blur.blurRadius = blurRadius
                blurView = blur
            } else {
                let blur = LFGlassView()
                blur.snapshotTargetView = snapshotTargetView
                blur.blurRadius = blurRadius
                blur.scaleFactor = scaleFactor
                blur.frameInterval = UInt(frameInterval)
                blur.isLiveBlurring = isLiveBlurring
                blurView = blur
            }
            if let blurView = blurView { addSubview(blurView) }
        }
    }

    private func setupLayers() {
        if !filterExclusions.contains(.tint) { layer.addSublayer(tintLayer) }
        if !filterExclusions.contains(.darken) { layer.addSublayer(darkenLayer) }
        if !filterExclusions.contains(.highlight) { layer.addSublayer(highlightLayer) }
        if !filterExclusions.contains(.depth) { layer.addSublayer(depthLayer) }
        if !filterExclusions.contains(.rim) { layer.addSublayer(rimLayer) }
        if !filterExclusions.contains(.innerShadow) { layer.addSublayer(innerShadowLayer) }
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        blurView?.frame = bounds
        solidView?.frame = bounds
        let layers = [tintLayer, darkenLayer, highlightLayer, depthLayer, rimLayer, innerShadowLayer]
        layers.forEach { $0.frame = bounds; $0.cornerRadius = cornerRadius }

        updateCornersAndShadow()
        updateGradientLayers()
    }

    private func updateCornersAndShadow() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset

        blurView?.layer.cornerRadius = cornerRadius
        solidView?.layer.cornerRadius = cornerRadius
    }

    private func updateGradientLayers() {
        if !filterExclusions.contains(.tint) {
            if let colors = tintGradientColors, !colors.isEmpty {
                tintLayer.colors = colors.map { $0.withIncreasedSaturation(factor: saturationBoost).cgColor }
                tintLayer.startPoint = CGPoint(x: 0.5, y: 0)
                tintLayer.endPoint = CGPoint(x: 0.5, y: 1)
            } else {
                tintLayer.backgroundColor = tintColorForGlass.withIncreasedSaturation(factor: saturationBoost).cgColor
            }
            tintLayer.compositingFilter = "softLightBlendMode"
        }

        if !filterExclusions.contains(.darken) {
            darkenLayer.colors = [UIColor.black.withAlphaComponent(0.22).cgColor, UIColor.clear.cgColor]
            darkenLayer.startPoint = CGPoint(x: 0.5, y: 1)
            darkenLayer.endPoint = CGPoint(x: 0.5, y: 0)
            darkenLayer.compositingFilter = "multiplyBlendMode"
        }

        if !filterExclusions.contains(.highlight) {
            highlightLayer.colors = [
                UIColor.white.withAlphaComponent(0.25).cgColor,
                UIColor.clear.cgColor,
                UIColor.white.withAlphaComponent(0.2).cgColor,
                UIColor.white.withAlphaComponent(0.1).cgColor
            ]
            highlightLayer.locations = [0.0, 0.25, 0.9, 1.0]
            highlightLayer.startPoint = CGPoint(x: 0, y: 0)
            highlightLayer.endPoint = CGPoint(x: 1, y: 1)
            highlightLayer.compositingFilter = "screenBlendMode"
        }

        if !filterExclusions.contains(.depth) {
            depthLayer.colors = [
                UIColor.black.withAlphaComponent(0.15).cgColor,
                UIColor.clear.cgColor,
                UIColor.white.withAlphaComponent(0.05).cgColor
            ]
            depthLayer.locations = [0.0, 0.6, 1.0]
            depthLayer.startPoint = CGPoint(x: 0.5, y: 1)
            depthLayer.endPoint = CGPoint(x: 0.5, y: 0)
            depthLayer.compositingFilter = "softLightBlendMode"
        }

        if !filterExclusions.contains(.rim) {
            rimLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            rimLayer.borderWidth = 0.8
        }

        if !filterExclusions.contains(.innerShadow) {
            drawInnerShadowDynamic()
        }
    }

    private func drawInnerShadowDynamic() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius * 0.85)
        UIView().drawInnerShadow(
            path: path,
            shadowColor: UIColor.black.withAlphaComponent(0.5),
            offset: CGSize(width: 0, height: 2),
            blurRadius: 6
        )
        if let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            innerShadowLayer.contents = image
        }
    }

    public func updateBlur() {
        blurView?.removeFromSuperview()
        solidView?.removeFromSuperview()
        setupBlurOrSolidView()
    }
}

// MARK: - Inner Shadow Helper
extension UIView {
    func drawInnerShadow(path: UIBezierPath, shadowColor: UIColor, offset: CGSize, blurRadius: CGFloat) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()
        context.addPath(path.cgPath)
        context.clip()

        let cgShadowColor = shadowColor.cgColor
        let opaqueShadowColor = cgShadowColor.copy(alpha: 1.0)

        context.setAlpha(cgShadowColor.alpha)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        context.setShadow(offset: offset, blur: blurRadius, color: opaqueShadowColor)
        context.setBlendMode(.sourceOut)
        context.setFillColor(opaqueShadowColor ?? UIColor.black.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        context.endTransparencyLayer()
        context.restoreGState()
    }
}
