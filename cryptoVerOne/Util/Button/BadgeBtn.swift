//
//  BadgeBtn.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import UIKit
import SnapKit

class BadgeBtn:UIButton {
    private lazy var badgeIcon:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 8)
        label.backgroundColor = Themes.badgeBackgroundRed
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       setupViews()
    }
    
    private func setupViews(){
        addSubview(badgeIcon)
        layoutIfNeeded()
        let iconWidth = self.frame.width/3
        let distance = self.frame.width/2 - CGFloat(2.0.squareRoot()/2)*self.frame.width/2 - iconWidth/2
        badgeIcon.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: iconWidth, height: iconWidth))
            maker.trailing.equalToSuperview().offset(-distance)
            maker.top.equalToSuperview().offset(distance)
        }
    }
    
    func setBadge(_ number:Int) {
        badgeIcon.isHidden = !(number > 0)
        badgeIcon.text = "\(number)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        badgeIcon.applyCornerRadius(radius: badgeIcon.frame.width/2)
    }
    
}
