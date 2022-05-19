//
//  SaveButton.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/19.
//

import Foundation
class SaveButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setBackgroundImage(UIImage(color: Themes.grayE0E5F2) , for: .disabled)
        setBackgroundImage(UIImage(color: Themes.grayE0E5F2) , for: .normal)
        setTitleColor(Themes.gray707EAE, for: .disabled)
        setTitleColor(Themes.gray707EAE, for: .normal)
        titleLabel?.font = Fonts.interSemiBold(16)
        layer.cornerRadius = rect.height / 2
        layer.borderColor = #colorLiteral(red: 0.6392156863, green: 0.6823529412, blue: 0.8156862745, alpha: 0.3963759629).cgColor
        layer.borderWidth = 1
        clipsToBounds = true
    }
}
