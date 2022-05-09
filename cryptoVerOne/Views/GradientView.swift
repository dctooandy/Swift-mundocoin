//
//  GradientView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import UIKit
class GradientView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addGradientLayer(colors: [Themes.primaryBase.cgColor, Themes.primaryDark.cgColor], direction: .toRight)
    }
}
