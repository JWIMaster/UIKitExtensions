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
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            if let windowScene = self.window?.windowScene,
               let frame = windowScene.statusBarManager?.statusBarFrame {
                statusBarFrame = frame
            } else {
                statusBarFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: UIApplication.shared.statusBarFrame.height)
            }
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }

        let statusBarBackground = UIView(frame: statusBarFrame)
        statusBarBackground.backgroundColor = backgroundColor
        statusBarBackground.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        statusBarBackground.isUserInteractionEnabled = false
        
        let statusBarTextContainer = UIStackView()
        statusBarTextContainer.frame = statusBarBackground.frame
        statusBarTextContainer.axis = .horizontal
        statusBarTextContainer.alignment = .center
        statusBarTextContainer.distribution = .fillEqually
        statusBarTextContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let a = UILabel()
        a.text = "1"
        a.translatesAutoresizingMaskIntoConstraints = false
        a.textColor = .black
        statusBarTextContainer.addArrangedSubview(a)
        statusBarBackground.addSubview(statusBarTextContainer)
        statusBarBackground.bringSubviewToFront(statusBarTextContainer)
        
        NSLayoutConstraint.activate([
            statusBarTextContainer.centerXAnchor.constraint(equalTo: statusBarTextContainer.centerXAnchor),
            statusBarTextContainer.centerYAnchor.constraint(equalTo: statusBarTextContainer.centerYAnchor)
        ])

        self.addSubview(statusBarBackground)
        self.bringSubviewToFront(statusBarBackground)
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
