import UIKit
import LiveFrost
import GPUImage1Swift

public class LiquidGlassView: LFGlassView {

    // MARK: - Public properties
    public var cornerRadius: CGFloat = 50 {
        didSet {
            layer.cornerRadius = cornerRadius
            overlayLayer.cornerRadius = cornerRadius
            updateShadow()
            updateMask()
        }
    }

    public var shadowOpacity: Float = 0.6 {
        didSet { updateShadow() }
    }

    public var shadowRadius: CGFloat = 30 {
        didSet { updateShadow() }
    }

    public var shadowOffset: CGSize = CGSize(width: 0, height: 25) {
        didSet { updateShadow() }
    }

    public var saturationBoost: CGFloat = 1.1 {
        didSet { applySaturationBoost() }
    }

    // MARK: - Single overlay layer
    private let overlayLayer = CALayer()
    private var saturationFilter: GPUImageSaturationFilter?

    // MARK: - Init
    public init(blurRadius: CGFloat = 12, cornerRadius: CGFloat = 50) {
        super.init(frame: .zero)
        self.blurRadius = blurRadius
        self.cornerRadius = cornerRadius
        isLiveBlurring = true
        setupOverlay()
        applySaturationBoost()
        updateShadow()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isLiveBlurring = true
        setupOverlay()
        applySaturationBoost()
        updateShadow()
    }

    // MARK: - Overlay setup
    private func setupOverlay() {
        overlayLayer.cornerRadius = cornerRadius
        overlayLayer.masksToBounds = true
        overlayLayer.contents = createOverlayTexture()
        overlayLayer.compositingFilter = "overlayBlendMode"
        layer.addSublayer(overlayLayer)
    }

    // MARK: - Create combined overlay texture
    private func createOverlayTexture() -> CGImage? {
        let size = bounds.size
        guard size.width > 0, size.height > 0 else { return nil }

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        // Bluish tint
        ctx.setFillColor(UIColor.blue.withAlphaComponent(0.05).cgColor)
        ctx.fill(bounds)

        // Darken bottom edges
        let darkGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.black.withAlphaComponent(0.22).cgColor, UIColor.clear.cgColor] as CFArray,
            locations: [0, 1]
        )!
        ctx.drawLinearGradient(darkGradient,
                               start: CGPoint(x: size.width/2, y: size.height),
                               end: CGPoint(x: size.width/2, y: 0),
                               options: [])

        // Inner highlight (subtle white gradient)
        let highlightGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.white.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor] as CFArray,
            locations: [0, 1]
        )!
        ctx.drawLinearGradient(highlightGradient,
                               start: CGPoint(x: 0, y: 0),
                               end: CGPoint(x: size.width, y: size.height),
                               options: [])

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.cgImage
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        overlayLayer.frame = bounds
        updateMask()
    }

    private func updateMask() {
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.mask = mask
    }

    private func updateShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }

    private func applySaturationBoost() {
        #if canImport(GPUImage1Swift)
        saturationFilter = GPUImageSaturationFilter()
        saturationFilter?.saturation = saturationBoost
        #endif
    }
}
