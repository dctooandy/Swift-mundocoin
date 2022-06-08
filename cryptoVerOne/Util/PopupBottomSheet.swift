//
//  PopupBottomSheet.swift
//  betlead
//
//  Created by Andy Chen on 2019/5/31.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
class PopupBottomSheet:BottomSheet {
    
    lazy var dismissButton:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "icon-close-round-fill") , for: .normal)
        btn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return btn
    }()
    
    override func setupViews() {
        super.setupViews()
        defaultContainer.applyCornerRadius(radius: 20)
        view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-80)
            maker.size.equalTo(CGSize(width: 30, height: 30) )
        }
    }
}
