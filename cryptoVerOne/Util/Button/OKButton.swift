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
        setBackgroundImage(UIImage(color: Themes.grayLightDarker), for: .normal)
        clipsToBounds = true
        layer.cornerRadius = rect.height / 2
        layer.borderColor = Themes.grayLightDarker.cgColor
        layer.borderWidth = 1
        setTitleColor(.white, for: .normal)
    }
 

}
