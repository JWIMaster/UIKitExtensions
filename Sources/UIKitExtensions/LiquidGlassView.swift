//
//  LiquidGlassView.swift
//

import UIKit
import GPUImage1Swift
import LiveFrost

public class LiquidGlassView: LFGlassView {

    // MARK: - Public properties
    public var cornerRadius: CGFloat = 50 {
        didSet {
            // root layer corner used only for shadow path visual consistency
            layer.cornerRadius = cornerRadius
            contentContainer.layer.cornerRadius = cornerRadius
            layoutIfNeeded()
            updateShadow()
            updateLayerCorners()
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

    // MARK: - Subviews and decorative layers
    private let contentContainer = UIView()
    private let tintOverlay = CALayer()
    private let cornerHighlightLayer = CAGradientLayer()
    private let darkenFalloffLayer = CAGradientLayer()
    private let innerDepthLayer = CAGradientLayer()
    private let refractLayer = CAGradientLayer()
    private let rimLayer = CALayer()
    private let diffractionLayer = CALayer()

    private var saturationFilter: GPUImageSaturationFilter?

    // MARK: - Init
    public init(blurRadius: CGFloat = 12, cornerRadius: CGFloat = 50) {
        super.init(frame: .zero)
        self.blurRadius = blurRadius
        self.cornerRadius = cornerRadius
        isLiveBlurring = true

        setupHierarchy()
        setupLayers()
        applySaturationBoost()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isLiveBlurring = true

        setupHierarchy()
        setupLayers()
        applySaturationBoost()
    }

    // MARK: - View hierarchy
    private func setupHierarchy() {
        // allow shadow to draw outside bounds
        clipsToBounds = false
        layer.masksToBounds = false

        // content container holds blur and all overlays, and is clipped
        contentContainer.clipsToBounds = true
        contentContainer.layer.masksToBounds = true
        contentContainer.layer.cornerRadius = cornerRadius
        contentContainer.backgroundColor = .clear

        // insert content container below any potential other UI you may add
        addSubview(contentContainer)

        // important: if LFGlassView draws blur into its own layer, ensure its content
        // appears inside the container. If LFGlassView expects to be the drawing layer,
        // you may need to add a backing view for the blur as a subview of contentContainer.
        // Here we rely on contentContainer to host the decorative sublayers only.
    }

    // MARK: - Setup layers
    private func setupLayers() {
        updateShadow()

        // Bluish tint
        tintOverlay.backgroundColor = UIColor.blue.withAlphaComponent(0.05).cgColor
        tintOverlay.cornerRadius = cornerRadius
        tintOverlay.compositingFilter = "overlayBlendMode"
        contentContainer.layer.addSublayer(tintOverlay)

        // Darken edges
        darkenFalloffLayer.colors = [
            UIColor.black.withAlphaComponent(0.22).cgColor,
            UIColor.clear.cgColor
        ]
        darkenFalloffLayer.startPoint = CGPoint(x: 0.5, y: 1)
        darkenFalloffLayer.endPoint = CGPoint(x: 0.5, y: 0)
        darkenFalloffLayer.locations = [0, 1]
        darkenFalloffLayer.compositingFilter = "multiplyBlendMode"
        contentContainer.layer.addSublayer(darkenFalloffLayer)

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
        contentContainer.layer.addSublayer(cornerHighlightLayer)

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
        contentContainer.layer.addSublayer(innerDepthLayer)

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
        contentContainer.layer.addSublayer(refractLayer)

        // Outer rim
        rimLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        rimLayer.borderWidth = 0.8
        rimLayer.cornerRadius = cornerRadius
        contentContainer.layer.addSublayer(rimLayer)

        // Diffraction / micro refraction
        diffractionLayer.backgroundColor = UIColor.white.withAlphaComponent(0.03).cgColor
        diffractionLayer.cornerRadius = max(0, cornerRadius - 1)
        diffractionLayer.compositingFilter = "differenceBlendMode"
        contentContainer.layer.addSublayer(diffractionLayer)
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()

        // place container to match root bounds
        contentContainer.frame = bounds

        layoutLayers()
        updateLayerCorners()
        updateShadow()
    }

    private func layoutLayers() {
        let inset: CGFloat = 2
        tintOverlay.frame = contentContainer.bounds
        darkenFalloffLayer.frame = contentContainer.bounds
        cornerHighlightLayer.frame = contentContainer.bounds
        innerDepthLayer.frame = contentContainer.bounds.insetBy(dx: inset * 0.5, dy: inset * 0.5)
        refractLayer.frame = contentContainer.bounds.insetBy(dx: contentContainer.bounds.width * 0.05,
                                                             dy: contentContainer.bounds.height * 0.05)
        rimLayer.frame = contentContainer.bounds
        diffractionLayer.frame = contentContainer.bounds.insetBy(dx: inset, dy: inset)
    }

    private func updateLayerCorners() {
        tintOverlay.cornerRadius = cornerRadius
        rimLayer.cornerRadius = cornerRadius
        diffractionLayer.cornerRadius = max(0, cornerRadius - 1)
        contentContainer.layer.cornerRadius = cornerRadius
    }

    private func updateShadow() {
        // Root layer retains shadow. Keep masksToBounds false so shadow can draw.
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset

        // Use a rounded shadow path for performance and stability
        let shadowRect = bounds
        if shadowRect.width > 0 && shadowRect.height > 0 {
            layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: cornerRadius).cgPath
        } else {
            layer.shadowPath = nil
        }

        // modern iOS niceties
        layer.allowsEdgeAntialiasing = true
        layer.shouldRasterize = false
        layer.rasterizationScale = UIScreen.main.scale

        // ensure content layer antialiasing for smoother corners
        contentContainer.layer.allowsEdgeAntialiasing = true
        contentContainer.layer.contentsScale = UIScreen.main.scale
    }

    private func applySaturationBoost() {
        #if canImport(GPUImage1Swift)
        saturationFilter = GPUImageSaturationFilter()
        saturationFilter?.saturation = saturationBoost
        #endif
    }
}
