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

    public var shadowRadius: CGFloat = 12 {
        didSet { updateCornersAndShadow() }
    }

    public var shadowColor: CGColor = UIColor.black.cgColor {
        didSet { updateCornersAndShadow() }
    }

    public var shadowOffset: CGSize = .zero {
        didSet { updateCornersAndShadow() }
    }

    public var saturationBoost: CGFloat = 1.1 {
        didSet { applySaturationBoost() }
    }

    public var blurRadius: CGFloat = 12 {
        didSet { blurView?.blurRadius = blurRadius }
    }

    public var scaleFactor: CGFloat = 0.4 {
        didSet { blurView?.scaleFactor = scaleFactor }
    }

    public var frameInterval: Int = 3 {
        didSet { blurView?.frameInterval = UInt(frameInterval) }
    }
    
    public var isLiveBlurring: Bool = true {
        didSet { blurView?.isLiveBlurring = isLiveBlurring }
    }

    public weak var snapshotTargetView: UIView? {
        didSet { blurView?.snapshotTargetView = snapshotTargetView }
    }
    
    public var tintColorForGlass: UIColor = UIColor.blue.withAlphaComponent(0.05) {
        didSet {
            tintOverlay.backgroundColor = tintColorForGlass.cgColor
        }
    }
    
    public var solidViewColour: UIColor = .clear {
        didSet {
            solidView?.backgroundColor = solidViewColour
        }
    }

    /// NEW: disable blur completely
    public var disableBlur: Bool = false

    // MARK: - Subviews
    public var blurView: LFGlassView?
    public var solidView: UIView?
    private let tintOverlay = CALayer()
    private let cornerHighlightLayer = CAGradientLayer()
    private let darkenFalloffLayer = CAGradientLayer()
    private let innerDepthLayer = CAGradientLayer()
    private let refractLayer = CAGradientLayer()
    private let rimLayer = CALayer()
    private let diffractionLayer = CALayer()
    private let flattenedDecorLayer = CALayer()   // flattened composite layer

    private var saturationFilter: GPUImageSaturationFilter?
    
    private static var cachedImages: [CacheKey: CGImage] = [:]

    // MARK: - Init
    public init(blurRadius: CGFloat = 12, cornerRadius: CGFloat = 50, snapshotTargetView: UIView?, disableBlur: Bool = false) {
        super.init(frame: .zero)
        self.cornerRadius = cornerRadius
        self.blurRadius = blurRadius
        self.snapshotTargetView = snapshotTargetView
        self.disableBlur = disableBlur
        if !disableBlur {
            let blur = LFGlassView()
            blur.snapshotTargetView = snapshotTargetView
            blur.blurRadius = blurRadius
            blurView = blur
        } else {
            solidView = UIView()
        }
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
        
        if disableBlur {
            if let solidView = solidView {
                solidView.layer.cornerRadius = cornerRadius
                solidView.layer.masksToBounds = true
                addSubview(solidView)
                sendSubviewToBack(solidView)
            }
        } else if let blurView = blurView {
            blurView.isLiveBlurring = true
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.masksToBounds = true
            addSubview(blurView)
        }
    }

    private func setupLayers() {
        // configure decorative layers
        tintOverlay.backgroundColor = UIColor.blue.withAlphaComponent(0.05).cgColor
        tintOverlay.compositingFilter = "softLightBlendMode"
        tintOverlay.cornerRadius = cornerRadius

        darkenFalloffLayer.colors = [UIColor.black.withAlphaComponent(0.22).cgColor, UIColor.clear.cgColor]
        darkenFalloffLayer.startPoint = CGPoint(x: 0.5, y: 1)
        darkenFalloffLayer.endPoint = CGPoint(x: 0.5, y: 0)
        darkenFalloffLayer.compositingFilter = "multiplyBlendMode"
        darkenFalloffLayer.cornerRadius = cornerRadius

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
        cornerHighlightLayer.cornerRadius = cornerRadius

        innerDepthLayer.colors = [
            UIColor.black.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        innerDepthLayer.locations = [0.0, 0.6, 1.0]
        innerDepthLayer.startPoint = CGPoint(x: 0.5, y: 1)
        innerDepthLayer.endPoint = CGPoint(x: 0.5, y: 0)
        innerDepthLayer.compositingFilter = "softLightBlendMode"
        innerDepthLayer.cornerRadius = cornerRadius

        refractLayer.colors = [
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        refractLayer.locations = [0.0, 0.1, 1.0]
        refractLayer.startPoint = CGPoint(x: 0, y: 0)
        refractLayer.endPoint = CGPoint(x: 1, y: 1)
        refractLayer.compositingFilter = "differenceBlendMode"
        refractLayer.cornerRadius = cornerRadius

        rimLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        rimLayer.borderWidth = 0.8
        rimLayer.cornerRadius = cornerRadius

        diffractionLayer.backgroundColor = UIColor.white.withAlphaComponent(0.03).cgColor
        diffractionLayer.compositingFilter = "differenceBlendMode"
        diffractionLayer.cornerRadius = cornerRadius - 1

        // add flattened composite holder
        layer.addSublayer(flattenedDecorLayer)

        updateCornersAndShadow()
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()

        if let blurView = blurView {
            blurView.frame = bounds
        }
        
        if let solidView = solidView {
            solidView.frame = bounds
        }

        // Position layers temporarily for flattening
        let inset: CGFloat = 2
        let layersToFlatten: [CALayer] = [
            tintOverlay,
            darkenFalloffLayer,
            cornerHighlightLayer,
            innerDepthLayer,
            //refractLayer,
            rimLayer
            //diffractionLayer
        ]

        tintOverlay.frame = bounds
        darkenFalloffLayer.frame = bounds
        cornerHighlightLayer.frame = bounds
        innerDepthLayer.frame = bounds.insetBy(dx: inset * 0.5, dy: inset * 0.5)
        refractLayer.frame = bounds.insetBy(dx: bounds.width * 0.05, dy: bounds.height * 0.05)
        rimLayer.frame = bounds
        diffractionLayer.frame = bounds.insetBy(dx: inset, dy: inset)

        // flatten layers
        let key = CacheKey(size: bounds.size, tint: tintColorForGlass)
        if let cached = LiquidGlassView.cachedImages[key] {
            flattenedDecorLayer.contents = cached
            print("used cache")
        } else {
            let tempLayer = CALayer()
            layersToFlatten.forEach { tempLayer.addSublayer($0) }

            // recolour tint overlay before render
            tintOverlay.backgroundColor = tintColorForGlass.cgColor

            UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
            if let ctx = UIGraphicsGetCurrentContext() {
                tempLayer.render(in: ctx)
            }
            let img = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()

            if let img = img {
                LiquidGlassView.cachedImages[key] = img
                flattenedDecorLayer.contents = img
            }
        }

        flattenedDecorLayer.frame = bounds
        flattenedDecorLayer.cornerRadius = cornerRadius
        flattenedDecorLayer.masksToBounds = true

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius * 0.85
        ).cgPath
    }

    private func updateCornersAndShadow() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        solidView?.layer.cornerRadius = cornerRadius
        blurView?.layer.cornerRadius = cornerRadius
        flattenedDecorLayer.cornerRadius = cornerRadius
    }

    private func applySaturationBoost() {
        #if canImport(GPUImage1Swift)
        saturationFilter = GPUImageSaturationFilter()
        saturationFilter?.saturation = saturationBoost
        #endif
    }
}


fileprivate struct CacheKey: Hashable {
    let width: CGFloat
    let height: CGFloat
    let tintHex: UInt32
    
    init(size: CGSize, tint: UIColor) {
        width = (size.width * 100).rounded() / 100
        height = (size.height * 100).rounded() / 100
        tintHex = tint.hexValue
    }
}

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
