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
#if Approval_PRO || Approval_DEV || Approval_STAGE
        setBackgroundImage(UIImage(color: Themes.green13BBB1) , for: .normal)
        layer.cornerRadius = 8
#else
        setBackgroundImage(UIImage(color: Themes.purple6149F6) , for: .normal)
        layer.cornerRadius = rect.height / 2
#endif
        setTitleColor(Themes.grayA3AED0, for: .disabled)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Fonts.interSemiBold(16)
        clipsToBounds = true
    }
}
