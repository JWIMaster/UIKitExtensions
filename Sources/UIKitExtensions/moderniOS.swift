//
//  File.swift
//  
//
//  Created by JWI on 5/10/2025.
//

import Foundation
import UIKit
import UIKitCompatKit

extension UINavigationController {
    public func moderniOS() {
        self.navigationBar.backgroundColor = .white
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = .white
    }
}

extension UIView {
    public func moderniOSStatusBar(backgroundColor: UIColor = .white) {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let statusBar = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: statusBarHeight))
        statusBar.backgroundColor = .black
        statusBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        
        self.addSubview(statusBar)
        self.bringSubviewToFront(statusBar)
    }
}

extension UIWindow {
    public func moderniOS(backgroundColor: UIColor = .white) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = self.windowScene?.statusBarManager?.statusBarFrame ?? CGRect(x: 0, y: 0, width: self.bounds.width, height: 20)
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        
        let statusBarBackground = UIView(frame: statusBarFrame)
        statusBarBackground.backgroundColor = backgroundColor
        statusBarBackground.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        statusBarBackground.isUserInteractionEnabled = false

        self.addSubview(statusBarBackground)
        self.bringSubviewToFront(statusBarBackground)
    }
}
