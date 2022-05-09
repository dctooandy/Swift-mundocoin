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
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
    }

}
