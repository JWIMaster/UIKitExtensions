import UIKit
import GPUImage1Swift
import LiveFrost
import FoundationCompatKit

public class LiquidGlassView: UIView {

    public var cornerRadius: CGFloat = 50 { didSet { updateCornersAndShadow() } }
    public var shadowOpacity: Float = 0.6 { didSet { updateCornersAndShadow() } }
    public var shadowRadius: CGFloat = 12 { didSet { updateCornersAndShadow() } }
    public var shadowColor: CGColor = UIColor.black.cgColor { didSet { updateCornersAndShadow() } }
    public var shadowOffset: CGSize = .zero { didSet { updateCornersAndShadow() } }
    public var saturationBoost: CGFloat = 1.1 { didSet { applySaturationBoost() } }
    public var blurRadius: CGFloat = 12 { didSet { blurView?.blurRadius = blurRadius } }
    public var scaleFactor: CGFloat = 0.4 { didSet { blurView?.scaleFactor = scaleFactor } }
    public var frameInterval: Int = 3 { didSet { blurView?.frameInterval = UInt(frameInterval) } }
    public var isLiveBlurring: Bool = true { didSet { blurView?.isLiveBlurring = isLiveBlurring } }
    public weak var snapshotTargetView: UIView? { didSet { blurView?.snapshotTargetView = snapshotTargetView } }
    public var tintColorForGlass: UIColor = UIColor.blue.withAlphaComponent(0.05) {
        didSet {
            renderDecorLayer()
        }
    }
    public var solidViewColour: UIColor = .clear { didSet { solidView?.backgroundColor = solidViewColour } }
    public var disableBlur: Bool = false

    // Subviews
    public var blurView: LFGlassView?
    public var solidView: UIView?
    
    private var decorLayer = CALayer()
    private var saturationFilter: GPUImageSaturationFilter?

    private static let renderQueue = DispatchQueue(label: "com.yourapp.liquidglass.render", attributes: .concurrent, target: .global(qos: .userInitiated))
    
    private var renderCache: NSCache<NSString, CGImage> {
        LiquidGlassCache.shared.cache
    }
    
    private var lastRenderedSize: CGSize = .zero

    private func cacheKey(for size: CGSize, color: UIColor) -> NSString {
        let scale = UIScreen.main.scale
        // Round size to avoid floating-point inaccuracies
        let w = Int(size.width * scale)
        let h = Int(size.height * scale)
        let colorHex = color.hexValue
        return "\(w)x\(h)_\(colorHex)" as NSString
    }

    
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
        renderDecorLayer()
        applySaturationBoost()
        
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        renderDecorLayer()
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
            }
        } else if let blurView = blurView {
            blurView.isLiveBlurring = true
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.masksToBounds = true
            addSubview(blurView)
        }

        decorLayer.cornerRadius = cornerRadius
        decorLayer.masksToBounds = true
        layer.addSublayer(decorLayer)
    }

    // MARK: - Render Decor Layer
    private func renderDecorLayer() {
        let size = bounds.size
        let key = cacheKey(for: size, color: self.tintColorForGlass)

        // Reuse cached base image (no tint)
        if let cachedImage = self.renderCache.object(forKey: key) {
            //print("usedcache")
            decorLayer.contents = cachedImage
            return
        }
        
        guard bounds.width > 0, bounds.height > 0 else {
            //print("Skipping render — zero bounds: \(bounds)")
            return
        }
        
        guard self.window != nil else {
            //print("Skipping render - no parent window")
            return
        }

        
        print("\(Date()) render \(key)")
        let tempLayer = CALayer()
        
        let tintLayer = CALayer()
        tintLayer.name = "tintLayer"
        tintLayer.backgroundColor = tintColorForGlass.cgColor
        tintLayer.frame = bounds
        tintLayer.cornerRadius = cornerRadius
        tintLayer.masksToBounds = true
        tintLayer.compositingFilter = "softLightBlendMode"
        tempLayer.addSublayer(tintLayer)
        
        // Darken falloff
        let darken = CAGradientLayer()
        darken.colors = [UIColor.black.withAlphaComponent(0.22).cgColor, UIColor.clear.cgColor]
        darken.startPoint = CGPoint(x: 0.5, y: 1)
        darken.endPoint = CGPoint(x: 0.5, y: 0)
        darken.cornerRadius = cornerRadius
        darken.compositingFilter = "multiplyBlendMode"
        darken.frame = bounds
        tempLayer.addSublayer(darken)

        // Corner highlight
        let highlight = CAGradientLayer()
        highlight.colors = [
            UIColor.white.withAlphaComponent(0.25).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor
        ]
        highlight.locations = [0.0, 0.25, 0.9, 1.0]
        highlight.startPoint = CGPoint(x: 0, y: 0)
        highlight.endPoint = CGPoint(x: 1, y: 1)
        highlight.cornerRadius = cornerRadius
        highlight.compositingFilter = "screenBlendMode"
        highlight.frame = bounds
        tempLayer.addSublayer(highlight)

        // Inner depth
        let innerDepth = CAGradientLayer()
        innerDepth.colors = [
            UIColor.black.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        innerDepth.locations = [0.0, 0.6, 1.0]
        innerDepth.startPoint = CGPoint(x: 0.5, y: 1)
        innerDepth.endPoint = CGPoint(x: 0.5, y: 0)
        innerDepth.cornerRadius = cornerRadius
        innerDepth.compositingFilter = "softLightBlendMode"
        innerDepth.frame = bounds
        tempLayer.addSublayer(innerDepth)

        // Rim
        let rim = CALayer()
        rim.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        rim.borderWidth = 0.8
        rim.cornerRadius = cornerRadius
        rim.frame = bounds
        tempLayer.addSublayer(rim)

        // Render background asynchronously
        LiquidGlassView.renderQueue.async { [weak self] in
            guard let self = self else { return }

            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            if let ctx = UIGraphicsGetCurrentContext() {
                tempLayer.render(in: ctx)
            }
            guard let renderedImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
                UIGraphicsEndImageContext()
                return
            }
            UIGraphicsEndImageContext()
            tempLayer.sublayers?.removeAll()

            self.renderCache.setObject(renderedImage, forKey: key)

            DispatchQueue.main.async {
                self.decorLayer.contents = renderedImage
            }
        }
    }



    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        blurView?.frame = bounds
        solidView?.frame = bounds
        decorLayer.frame = bounds
        if bounds.size != lastRenderedSize {
            lastRenderedSize = bounds.size
            renderDecorLayer()
        }
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius * 0.85
        ).cgPath
        updateCornersAndShadow()
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
    }

    private func applySaturationBoost() {
        saturationFilter = GPUImageSaturationFilter()
        saturationFilter?.saturation = saturationBoost
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

public final class LiquidGlassCache {
    public static let shared = LiquidGlassCache()
    public let cache = NSCache<NSString, CGImage>()

    public init() {
        cache.countLimit = 300
        cache.totalCostLimit = 80_000_000
    }
}


