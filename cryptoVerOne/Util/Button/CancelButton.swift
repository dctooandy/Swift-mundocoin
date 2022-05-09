//
//  CancelButton.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import UIKit

class CancelButton: UIButton {

    override func draw(_ rect: CGRect) {
        setBackgroundImage(UIImage(color: Themes.primaryBase), for: .normal)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
    }
    
}
