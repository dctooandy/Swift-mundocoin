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
class BalanceGradientView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addGradientLayer(colors: [Themes.gray6149F6.cgColor, Themes.gray1CD0C5.cgColor], direction: .toRight)
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
    }
}
