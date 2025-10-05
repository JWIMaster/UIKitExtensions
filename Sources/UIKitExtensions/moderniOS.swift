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
    public func moderniOSNavBar() {
        self.navigationBar.backgroundColor = .white
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = .white
    }
}

extension UIWindow {
    public func moderniOSStatusBar(backgroundColor: UIColor = .white) {
        if #available(iOS 50, *) {
            return
        } else {
            let statusBar = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 20))
            statusBar.backgroundColor = backgroundColor
            statusBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            
            let timeLabel = UILabel()
            timeLabel.textAlignment = .center
            timeLabel.textColor = .black
            timeLabel.backgroundColor = .clear
            if #unavailable(iOS 20) {
                timeLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .bold)
            }
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            
            timeLabel.text = timeFormatter.string(from: Date())
            
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                timeLabel.text = timeFormatter.string(from: Date())
            }
            
            statusBar.addSubview(timeLabel)
            
            timeLabel.centerXAnchor.constraint(equalTo: statusBar.centerXAnchor).isActive = true
            timeLabel.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor).isActive = true
            
            
            self.addSubview(statusBar)
            self.bringSubviewToFront(statusBar)
        }
    }
}
