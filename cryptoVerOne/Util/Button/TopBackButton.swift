//
//  TopBackButton.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/18.
//


import Foundation
import UIKit
import SnapKit

class TopBackButton:UIButton {
    var imageName : String!
    init(iconName :String = "icon-arrow-lef2") {
        super.init(frame: .zero)
        self.imageName = iconName
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews(){
        layoutIfNeeded()
        let image = UIImage(named:imageName)
        frame = CGRect(x: 0, y: 0, width: Views.backImageHeight(), height: Views.backImageHeight())
        setImage(image, for: .normal)
        setTitle("", for:.normal)
    }
    
 
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        badgeIcon.applyCornerRadius(radius: badgeIcon.frame.width/2)
    }
    
}
