//
//  StatusImageView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import UIKit
import SnapKit
class StatusImageView:UIImageView {
   @IBInspectable lazy var rightIconImageView:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    init(image:UIImage,rightIcon:UIImage){
        super.init(image: image)
        rightIconImageView.image = rightIcon
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews(){
        addSubview(rightIconImageView)
        layoutIfNeeded()
        let iconWidth = self.frame.width/3
        rightIconImageView.snp.makeConstraints { (maker) in
            maker.height.width.equalTo(iconWidth)
            maker.trailing.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
    
    
    
}
