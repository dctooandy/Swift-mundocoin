//
//  CornerradiusButton.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import UIKit

class CornerradiusButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setBackgroundImage(UIImage(color: Themes.grayE0E5F2) , for: .disabled)
        setBackgroundImage(UIImage(color: Themes.gray6149F6) , for: .normal)
        setTitleColor(Themes.grayA3AED0, for: .disabled)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Fonts.interSemiBold(16)
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
    }
}
