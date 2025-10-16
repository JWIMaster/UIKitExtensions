import UIKit
import LiveFrost
import UIKitCompatKit
import GPUImage1Swift

public func createLiquidGlass(frame: CGRect, blurRadius: CGFloat, cornerRadius: CGFloat) -> LFGlassView {
    let glass = LFGlassView()
    glass.frame = frame
    glass.blurRadius = blurRadius
    glass.scaleFactor = 1
    glass.layer.cornerRadius = cornerRadius
    glass.layer.masksToBounds = true
    glass.isUserInteractionEnabled = true

    // Shadow
    glass.layer.shadowColor = UIColor.black.cgColor
    glass.layer.shadowOpacity = 0.5
    glass.layer.shadowRadius = 20
    glass.layer.shadowOffset = CGSize(width: 0, height: 10)

    // Tint overlay
    let tintOverlay = CALayer()
    tintOverlay.frame = glass.bounds
    tintOverlay.backgroundColor = UIColor.blue.withAlphaComponent(0.05).cgColor
    tintOverlay.cornerRadius = cornerRadius
    glass.layer.addSublayer(tintOverlay)

    // Corner highlight
    let cornerHighlightLayer = CAGradientLayer()
    cornerHighlightLayer.frame = glass.bounds
    cornerHighlightLayer.colors = [
        UIColor.white.withAlphaComponent(0.25).cgColor,
        UIColor.clear.cgColor,
        UIColor.white.withAlphaComponent(0.2).cgColor,
        UIColor.white.withAlphaComponent(0.1).cgColor
    ]
    cornerHighlightLayer.locations = [0, 0.25, 0.9, 1]
    cornerHighlightLayer.startPoint = CGPoint(x: 0, y: 0)
    cornerHighlightLayer.endPoint = CGPoint(x: 1, y: 1)
    cornerHighlightLayer.compositingFilter = "screenBlendMode"
    glass.layer.addSublayer(cornerHighlightLayer)

    // Inner depth gradient
    let innerDepthLayer = CAGradientLayer()
    innerDepthLayer.frame = glass.bounds.insetBy(dx: 1, dy: 1)
    innerDepthLayer.colors = [
        UIColor.black.withAlphaComponent(0.15).cgColor,
        UIColor.clear.cgColor,
        UIColor.white.withAlphaComponent(0.05).cgColor
    ]
    innerDepthLayer.locations = [0, 0.6, 1]
    innerDepthLayer.startPoint = CGPoint(x: 0.5, y: 1)
    innerDepthLayer.endPoint = CGPoint(x: 0.5, y: 0)
    innerDepthLayer.compositingFilter = "softLightBlendMode"
    glass.layer.addSublayer(innerDepthLayer)

    // Outer rim
    let rimLayer = CALayer()
    rimLayer.frame = glass.bounds
    rimLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    rimLayer.borderWidth = 0.8
    rimLayer.cornerRadius = cornerRadius
    glass.layer.addSublayer(rimLayer)

    return glass
}
