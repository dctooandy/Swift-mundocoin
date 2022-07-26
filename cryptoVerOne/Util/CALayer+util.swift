//
//  CALayer+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import UIKit
extension CALayer {
    func addShadow() {
        self.shadowOffset = .zero
        self.shadowOpacity = 0.2
        self.shadowRadius = 16
        self.shadowColor = Themes.grayE0E5F2.cgColor
        self.masksToBounds = false
        if cornerRadius != 0 {
            addShadowWithRoundedCorners()
        }
    }
    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }
    private func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
                .forEach{ $0.roundCorners(radius: self.cornerRadius) }
            self.contents = nil
            if let sublayer = sublayers?.first,
                sublayer.name == "shadowLayer" {
                sublayer.removeFromSuperlayer()
            }
            let contentLayer = CALayer()
            contentLayer.name = "shadowLayer"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
}
