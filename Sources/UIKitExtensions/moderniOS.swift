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
    public func moderniOSStatusBar(backgroundColor: UIColor = .black) {
        
        
        let modernStatusBar = UIStackView()
        modernStatusBar.backgroundColor = backgroundColor
        modernStatusBar.axis = .horizontal
        modernStatusBar.alignment = .center
        modernStatusBar.distribution = .fillEqually
        modernStatusBar.translatesAutoresizingMaskIntoConstraints = false
        
        let a = UILabel()
        a.text = "1"
        a.textColor = .black
        a.backgroundColor = UIColor.green.withAlphaComponent(0.2)
        modernStatusBar.addArrangedSubview(a)
        
        modernStatusBar.pinToEdges(of: UIView(frame: UIApplication.shared.statusBarFrame))
        
        self.addSubview(modernStatusBar)
        self.bringSubviewToFront(modernStatusBar)
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
