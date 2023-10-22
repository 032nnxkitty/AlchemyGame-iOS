//
//  UIView+Intersection.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 27.09.2023.
//

import UIKit

extension UIView {
    func intersectionMoreThan50Percent(_ anotherView: UIView) -> Bool {
        let firstFrame = self.frame
        let secondFrame = anotherView.frame
        
        guard firstFrame.intersects(secondFrame) else { return false }
        let intersectionRect = firstFrame.intersection(secondFrame)
        let intersectionArea = intersectionRect.area
        let threshold = min(firstFrame.area, secondFrame.area) * 0.5
        return intersectionArea >= threshold
    }
}
