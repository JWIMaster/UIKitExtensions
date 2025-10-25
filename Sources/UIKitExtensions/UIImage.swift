//
//  File.swift
//  
//
//  Created by JWI on 24/10/2025.
//

import Foundation
import UIKit

public extension UIImage {
    static func solid(color: UIColor, size: CGSize = CGSize(width: 30, height: 30)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func resizeImage(toSize targetSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

public extension UIImage {
    func averageColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var rTotal: UInt = 0
        var gTotal: UInt = 0
        var bTotal: UInt = 0
        var aTotal: UInt = 0

        for x in 0..<width {
            for y in 0..<height {
                let idx = (y * width + x) * bytesPerPixel
                rTotal += UInt(pixelData[idx])
                gTotal += UInt(pixelData[idx + 1])
                bTotal += UInt(pixelData[idx + 2])
                aTotal += UInt(pixelData[idx + 3])
            }
        }

        let count = CGFloat(width * height)
        let r = CGFloat(rTotal) / count / 255.0
        let g = CGFloat(gTotal) / count / 255.0
        let b = CGFloat(bTotal) / count / 255.0
        let a = CGFloat(aTotal) / count / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
