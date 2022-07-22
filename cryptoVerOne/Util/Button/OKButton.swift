//
//  OKButton.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import UIKit

class OKButton: UIButton {

    var titleColor: UIColor? = nil
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setBackgroundImage(UIImage(color: Themes.blue6149F6), for: .normal)
        setBackgroundImage(UIImage(color: Themes.blue6149F6), for: .normal)
        titleLabel?.font = Fonts.interSemiBold(16)
        clipsToBounds = true
        layer.cornerRadius = rect.height / 2
        layer.borderColor = Themes.blue6149F6.cgColor
        layer.borderWidth = 1
        setTitleColor(.white, for: .normal)
    }
 

}
