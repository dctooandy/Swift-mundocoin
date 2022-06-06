//
//  BaseBottomSheet.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
class BaseBottomSheet:BottomSheet {
    var heightConstraint : NSLayoutConstraint!
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = Themes.grayDarkest
        return label
    }()
    
    lazy var serviceBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "icon-headphone"), for: .normal)
        return btn
    }()
    
    let separator = UIView(color: Themes.grayA3AED0)
    
//    lazy var submitBtn:UIButton = {
//        let btn = UIButton()
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
//        btn.setTitle("提交", for: .normal)
//        btn.setBackgroundImage(UIImage(color: Themes.grayBase) , for: .disabled)
//        btn.setBackgroundImage(UIImage(color: Themes.primaryBase) , for: .normal)
//        return btn
//    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ parameters: Any? = nil) {
       super.init()
    }
    
    override func setupViews() {
        super.setupViews()
        defaultContainer.addSubview(titleLabel)
        defaultContainer.addSubview(serviceBtn)
        defaultContainer.addSubview(separator)
//        defaultContainer.addSubview(submitBtn)
        
        heightConstraint = NSLayoutConstraint(item: defaultContainer, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: defaultContainerHeight + Views.bottomOffset)
        defaultContainer.snp.makeConstraints { (maker) in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.height.equalTo(heightConstraint.constant)
        }
        defaultContainer.addConstraint(heightConstraint)
        titleLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(25)
            maker.height.equalTo(22)
        }
        serviceBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(titleLabel.snp.centerY)
            maker.trailing.equalTo(-26)
            maker.size.equalTo(CGSize(width: 24, height: 24))
        }
        separator.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(titleLabel.snp.bottom).offset(25)
            maker.height.equalTo(1)
        }
//        submitBtn.snp.makeConstraints { (maker) in
//            maker.bottom.equalToSuperview()
//            maker.leading.trailing.equalToSuperview()
//            maker.height.equalTo(60 + Views.bottomOffset)
//        }
        
        view.layoutIfNeeded()
        defaultContainer.roundCorner(corners: [.topLeft,.topRight], radius: 18)
    }
}
