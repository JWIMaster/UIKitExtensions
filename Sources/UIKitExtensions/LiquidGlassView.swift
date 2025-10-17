import UIKit
import GPUImage1Swift
import LiveFrost

public class LiquidGlassView: LFGlassView {

    // MARK: - Public properties
    public var cornerRadius: CGFloat = 50 {
        didSet { updateCorners() }
    }

    public var shadowOpacity: Float = 0.6 { didSet { updateShadow() } }
    public var shadowRadius: CGFloat = 30 { didSet { updateShadow() } }
    public var shadowOffset: CGSize = CGSize(width: 0, height: 25) { didSet { updateShadow() } }
    public var saturationBoost: CGFloat = 1.1 { didSet { saturationFilter?.saturation = saturationBoost } }

    // MARK: - Layers
    private let tintOverlay = CALayer()
    private let cornerHighlightLayer = CAGradientLayer()
    private let darkenFalloffLayer = CAGradientLayer()
    private let innerDepthLayer = CAGradientLayer()
    private let refractLayer = CAGradientLayer()
    private let rimLayer = CALayer()
    private let diffractionLayer = CALayer()
    private var saturationFilter: GPUImageSaturationFilter?

    private let maskLayer = CAShapeLayer()

    // MARK: - Init
    public init(blurRadius: CGFloat = 12, cornerRadius: CGFloat = 50) {
        super.init(frame: .zero)
        self.blurRadius = blurRadius
        self.cornerRadius = cornerRadius
        isLiveBlurring = true
        setupLayers()
        applySaturationBoost()
        updateShadow()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isLiveBlurring = true
        setupLayers()
        applySaturationBoost()
        updateShadow()
    }

    // MARK: - Layer setup
    private func setupLayers() {
        clipsToBounds = true
        layer.masksToBounds = false

        // Tint overlay
        tintOverlay.backgroundColor = UIColor.blue.withAlphaComponent(0.05).cgColor
        tintOverlay.compositingFilter = "overlayBlendMode"
        layer.addSublayer(tintOverlay)

        // Darken edges
        darkenFalloffLayer.colors = [
            UIColor.black.withAlphaComponent(0.22).cgColor,
            UIColor.clear.cgColor
        ]
        darkenFalloffLayer.startPoint = CGPoint(x: 0.5, y: 1)
        darkenFalloffLayer.endPoint = CGPoint(x: 0.5, y: 0)
        darkenFalloffLayer.locations = [0, 1]
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

        // Inner depth
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

        // Refract layer
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

        // Rim & diffraction
        rimLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        rimLayer.borderWidth = 0.8
        layer.addSublayer(rimLayer)

        diffractionLayer.backgroundColor = UIColor.white.withAlphaComponent(0.03).cgColor
        diffractionLayer.compositingFilter = "differenceBlendMode"
        layer.addSublayer(diffractionLayer)

        // Mask
        layer.mask = maskLayer
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds != .zero else { return }

        let inset: CGFloat = 2
        tintOverlay.frame = bounds
        darkenFalloffLayer.frame = bounds
        cornerHighlightLayer.frame = bounds
        innerDepthLayer.frame = bounds.insetBy(dx: inset * 0.5, dy: inset * 0.5)
        refractLayer.frame = bounds.insetBy(dx: bounds.width * 0.05, dy: bounds.height * 0.05)
        rimLayer.frame = bounds
        diffractionLayer.frame = bounds.insetBy(dx: inset, dy: inset)

        updateCorners()
        updateMask()
    }

    private func updateMask() {
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    private func updateCorners() {
        layer.cornerRadius = cornerRadius
        tintOverlay.cornerRadius = cornerRadius
        rimLayer.cornerRadius = cornerRadius
        diffractionLayer.cornerRadius = max(cornerRadius - 1, 0)
    }

    private func updateShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }

    private func applySaturationBoost() {
        saturationFilter = GPUImageSaturationFilter()
        saturationFilter?.saturation = saturationBoost
    }
}
