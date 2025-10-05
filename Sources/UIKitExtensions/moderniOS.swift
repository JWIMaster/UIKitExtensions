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
    public func moderniOSStatusBar(backgroundColor: UIColor = .blue) {
        
        let statusBarTextContainer = UIStackView()
        statusBarTextContainer.frame = UIApplication.shared.statusBarFrame
        statusBarTextContainer.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        statusBarTextContainer.axis = .horizontal
        statusBarTextContainer.alignment = .center
        statusBarTextContainer.distribution = .fillEqually
        statusBarTextContainer.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        
        let a = UILabel()
        a.text = "1"
        a.textColor = .black
        a.backgroundColor = UIColor.green.withAlphaComponent(0.2)
        statusBarTextContainer.addArrangedSubview(a)

        self.addSubview(statusBarTextContainer)
        self.bringSubviewToFront(statusBarTextContainer)
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
