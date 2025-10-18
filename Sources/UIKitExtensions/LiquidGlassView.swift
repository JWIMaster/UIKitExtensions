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

    public var shadowColor: CGColor = UIColor.black.cgColor {
        didSet { updateCornersAndShadow() }
    }
    
    public var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
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
    public init(blurRadius: CGFloat = 12, cornerRadius: CGFloat = 50, snapshotTargetView: UIView?) {
        super.init(frame: .zero)
        self.cornerRadius = cornerRadius
        self.blurRadius = blurRadius
        self.snapshotTargetView = snapshotTargetView
        blurView.snapshotTargetView = snapshotTargetView
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
        clipsToBounds = true
        layer.masksToBounds = false

        blurView.isLiveBlurring = true
        blurView.layer.cornerRadius = cornerRadius
        blurView.layer.masksToBounds = true
        addSubview(blurView)
    }

    private let flattenedDecorLayer = CALayer()

    private func setupLayers() {
        // configure decorative layers (without adding them directly to self.layer)
        tintOverlay.backgroundColor = UIColor.blue.withAlphaComponent(0.05).cgColor
        tintOverlay.compositingFilter = "overlayBlendMode"
        
        darkenFalloffLayer.colors = [UIColor.black.withAlphaComponent(0.22).cgColor, UIColor.clear.cgColor]
        darkenFalloffLayer.startPoint = CGPoint(x: 0.5, y: 1)
        darkenFalloffLayer.endPoint = CGPoint(x: 0.5, y: 0)
        darkenFalloffLayer.compositingFilter = "multiplyBlendMode"
        
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

        innerDepthLayer.colors = [
            UIColor.black.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        innerDepthLayer.locations = [0.0, 0.6, 1.0]
        innerDepthLayer.startPoint = CGPoint(x: 0.5, y: 1)
        innerDepthLayer.endPoint = CGPoint(x: 0.5, y: 0)
        innerDepthLayer.compositingFilter = "softLightBlendMode"
        
        refractLayer.colors = [
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        refractLayer.locations = [0.0, 0.1, 1.0]
        refractLayer.startPoint = CGPoint(x: 0, y: 0)
        refractLayer.endPoint = CGPoint(x: 1, y: 1)
        refractLayer.compositingFilter = "differenceBlendMode"
        
        rimLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        rimLayer.borderWidth = 0.8
        
        diffractionLayer.backgroundColor = UIColor.white.withAlphaComponent(0.03).cgColor
        diffractionLayer.compositingFilter = "differenceBlendMode"

        // Flatten all decorative layers into one layer
        flattenedDecorLayer.frame = bounds
        flattenedDecorLayer.cornerRadius = cornerRadius
        flattenedDecorLayer.masksToBounds = true
        flattenedDecorLayer.contentsScale = UIScreen.main.scale
        
        // Render all sublayers into flattenedDecorLayer
        let tempLayer = CALayer()
        tempLayer.frame = bounds
        tempLayer.addSublayer(tintOverlay)
        tempLayer.addSublayer(darkenFalloffLayer)
        tempLayer.addSublayer(cornerHighlightLayer)
        tempLayer.addSublayer(innerDepthLayer)
        tempLayer.addSublayer(refractLayer)
        tempLayer.addSublayer(rimLayer)
        tempLayer.addSublayer(diffractionLayer)
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            tempLayer.render(in: context)
        }
        flattenedDecorLayer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        
        // Add flattened layer on top of blur
        layer.addSublayer(flattenedDecorLayer)
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
        layer.shadowPath = UIBezierPath(
            roundedRect: blurView.frame,
            cornerRadius: blurView.layer.cornerRadius*0.85
        ).cgPath
        updateLayerCorners()
    }

    private func updateCornersAndShadow() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor
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
