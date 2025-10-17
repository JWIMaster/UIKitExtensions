import UIKit
import GPUImage1Swift
import LiveFrost

public class LiquidGlassView: UIView {

    // MARK: - Public properties
    public var cornerRadius: CGFloat = 50 {
        didSet { updateCornersAndShadow() }
    }

    public var shadowOpacity: Float = 0.6 {
        didSet { updateCornersAndShadow() }
    }

    public var shadowRadius: CGFloat = 30 {
        didSet { updateCornersAndShadow() }
    }

    public var shadowOffset: CGSize = CGSize(width: 0, height: 25) {
        didSet { updateCornersAndShadow() }
    }

    public var saturationBoost: CGFloat = 1.1 {
        didSet { applySaturationBoost() }
    }

    public var blurRadius: CGFloat = 12 {
        didSet { blurView.blurRadius = blurRadius }
    }

    public var scaleFactor: CGFloat = 0.4 {
        didSet { blurView.scaleFactor = scaleFactor }
    }

    public var frameInterval: Int = 3 {
        didSet { blurView.frameInterval = UInt(frameInterval) }
    }

    public weak var snapshotTargetView: UIView? {
        didSet { blurView.snapshotTargetView = snapshotTargetView }
    }

    // MARK: - Subviews
    private let blurView = LFGlassView()
    private let tintOverlay = CALayer()
    private let cornerHighlightLayer = CAGradientLayer()
    private let darkenFalloffLayer = CAGradientLayer()
    private let innerDepthLayer = CAGradientLayer()
    private let refractLayer = CAGradientLayer()
    private let rimLayer = CALayer()
    private let diffractionLayer = CALayer()

    private var saturationFilter: GPUImageSaturationFilter?

    // MARK: - Init
    public init(blurRadius: CGFloat = 12, cornerRadius: CGFloat = 50, snaphshotTargetView: UIView?) {
        super.init(frame: .zero)
        self.cornerRadius = cornerRadius
        self.blurRadius = blurRadius
        self.snapshotTargetView = snaphshotTargetView
        setupView()
        setupLayers()
        applySaturationBoost()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayers()
        applySaturationBoost()
    }

    // MARK: - Setup
    private func setupView() {
        clipsToBounds = false
        layer.masksToBounds = false

        blurView.isLiveBlurring = true
        blurView.layer.cornerRadius = cornerRadius
        addSubview(blurView)
    }

    private func setupLayers() {
        // Bluish tint
        tintOverlay.backgroundColor = UIColor.blue.withAlphaComponent(0.05).cgColor
        tintOverlay.compositingFilter = "overlayBlendMode"
        layer.addSublayer(tintOverlay)

        // Darken edges
        darkenFalloffLayer.colors = [UIColor.black.withAlphaComponent(0.22).cgColor, UIColor.clear.cgColor]
        darkenFalloffLayer.startPoint = CGPoint(x: 0.5, y: 1)
        darkenFalloffLayer.endPoint = CGPoint(x: 0.5, y: 0)
        darkenFalloffLayer.compositingFilter = "multiplyBlendMode"
        layer.addSublayer(darkenFalloffLayer)

        // Corner highlights
        cornerHighlightLayer.colors = [
            UIColor.white.withAlphaComponent(0.25).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor
        ]
        cornerHighlightLayer.locations = [0.0, 0.25, 0.9, 1.0]
        cornerHighlightLayer.startPoint = CGPoint(x: 0, y: 0)
        cornerHighlightLayer.endPoint = CGPoint(x: 1, y: 1)
        cornerHighlightLayer.compositingFilter = "screenBlendMode"
        layer.addSublayer(cornerHighlightLayer)

        // Inner depth gradient
        innerDepthLayer.colors = [
            UIColor.black.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        innerDepthLayer.locations = [0.0, 0.6, 1.0]
        innerDepthLayer.startPoint = CGPoint(x: 0.5, y: 1)
        innerDepthLayer.endPoint = CGPoint(x: 0.5, y: 0)
        innerDepthLayer.compositingFilter = "softLightBlendMode"
        layer.addSublayer(innerDepthLayer)

        // Refractive rim
        refractLayer.colors = [
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        refractLayer.locations = [0.0, 0.1, 1.0]
        refractLayer.startPoint = CGPoint(x: 0, y: 0)
        refractLayer.endPoint = CGPoint(x: 1, y: 1)
        refractLayer.compositingFilter = "differenceBlendMode"
        layer.addSublayer(refractLayer)

        // Outer rim
        rimLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        rimLayer.borderWidth = 0.8
        layer.addSublayer(rimLayer)

        // Diffraction
        diffractionLayer.backgroundColor = UIColor.white.withAlphaComponent(0.03).cgColor
        diffractionLayer.compositingFilter = "differenceBlendMode"
        layer.addSublayer(diffractionLayer)

        updateCornersAndShadow()
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        let inset: CGFloat = 2
        tintOverlay.frame = bounds
        darkenFalloffLayer.frame = bounds
        cornerHighlightLayer.frame = bounds
        innerDepthLayer.frame = bounds.insetBy(dx: inset * 0.5, dy: inset * 0.5)
        refractLayer.frame = bounds.insetBy(dx: bounds.width * 0.05, dy: bounds.height * 0.05)
        rimLayer.frame = bounds
        diffractionLayer.frame = bounds.insetBy(dx: inset, dy: inset)
        updateLayerCorners()
    }

    private func updateCornersAndShadow() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset

        updateLayerCorners()
        blurView.layer.cornerRadius = cornerRadius
    }

    private func updateLayerCorners() {
        tintOverlay.cornerRadius = cornerRadius
        rimLayer.cornerRadius = cornerRadius
        diffractionLayer.cornerRadius = cornerRadius - 1
    }

    private func applySaturationBoost() {
        #if canImport(GPUImage1Swift)
        saturationFilter = GPUImageSaturationFilter()
        saturationFilter?.saturation = saturationBoost
        #endif
    }
}
