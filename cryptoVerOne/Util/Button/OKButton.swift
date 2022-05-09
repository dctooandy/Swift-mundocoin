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
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = rect.height / 2
        layer.borderColor = Themes.primaryBase.cgColor
        layer.borderWidth = 1
        setTitleColor(titleColor ?? Themes.primaryBase, for: .normal)
    }
 

}
