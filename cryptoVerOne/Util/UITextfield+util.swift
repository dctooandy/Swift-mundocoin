//
//  UITextfield+util.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import SnapKit
extension UITextField {
    
    func setMaskView() {
        let v = UIView()
//        v.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
        v.backgroundColor = .clear
        v.layer.borderWidth = 1
        v.layer.borderColor = Themes.grayLighter.cgColor
        v.isUserInteractionEnabled = false
        v.alpha = 1.0
        v.applyCornerRadius(radius: 10)
        addSubview(v)
        v.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.10)
            make.height.equalToSuperview().multipliedBy(Views.isIPhoneWithNotch() ? 1.0 : 1.1)
        }
    }
    
    func setPlaceholder(_ text: String, with color: UIColor) {
        
        self.attributedPlaceholder = NSAttributedString(string: text,
                                                        attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func addDownArrow(){
        let downArrowImageView = UIImageView(image: UIImage(named: "icon-down-arrow"))
        addSubview(downArrowImageView)
        downArrowImageView.snp.makeConstraints { (maker) in
            maker.trailing.equalToSuperview().offset(-12)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
    
    var rxText:String? {
        get{
            return text
        }
        set{
           text = newValue
           self.sendActions(for: .valueChanged)
        }
    }
}

class BottomSheetTextField:UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = Themes.grayLight.cgColor
        layer.borderWidth = 1
        textColor = Themes.grayBlack
        applyCornerRadius(radius: 4)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 48) )
        leftView = paddingView
        leftViewMode = .always
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
