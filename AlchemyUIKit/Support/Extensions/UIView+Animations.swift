//
//  UIView+Shake.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 12.09.2023.
//

import UIKit

extension UIView {
    func shake() {
        let keyPath = "position"
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 5, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 5, y: self.center.y)
        self.layer.add(animation, forKey: keyPath)
    }
    
    func wiggle() {
        let keyPath = "transform"
        let transformAnimation = CAKeyframeAnimation(keyPath: keyPath)
        let angle: CGFloat = Bool.random() ? 0.09 : 0.07
        transformAnimation.values = [
            CATransform3DMakeRotation(angle, 0, 0, 1),
            CATransform3DMakeRotation(-angle, 0, 0, 1)
        ]
        transformAnimation.autoreverses = true
        transformAnimation.duration = 0.115
        transformAnimation.repeatCount = .infinity
        self.layer.add(transformAnimation, forKey: keyPath)
    }
    
    func stopAnimation() {
        self.layer.removeAllAnimations()
    }
}
