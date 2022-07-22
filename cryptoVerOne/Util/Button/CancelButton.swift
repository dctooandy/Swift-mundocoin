//
//  CancelButton.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import UIKit

class CancelButton: UIButton {

    override func draw(_ rect: CGRect) {
        setBackgroundImage(UIImage(color: Themes.grayA3AED020), for: .normal)
        setTitleColor(Themes.gray707EAE, for: .normal)
        titleLabel?.font = Fonts.interSemiBold(16)
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
    }
    
}
