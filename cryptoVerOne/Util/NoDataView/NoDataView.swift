//
//  NoDataView.swift
//  cryptoVerOne
//
//  Created by BBk on 6/8/22.
//

import UIKit

class NoDataView: UIView {
    private let imv: UIImageView = UIImageView()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(28)
        lb.textColor = Themes.blue6149F6
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    private let subLabel: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangTCRegular(16)
        lb.numberOfLines = 0
        lb.textAlignment = .center
        lb.textColor = .black
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(image: UIImage?, title: String , subTitle:String) {
        super.init(frame: .zero)
        imv.image = image
        titleLabel.text = title
        subLabel.text = subTitle
        setup()
    }
    
    private func setup() {
        addSubview(imv)
        addSubview(titleLabel)
        addSubview(subLabel)
        imv.contentMode = .scaleAspectFill
        imv.snp.makeConstraints { (make) in
//            let s = sizeFrom(scale: 0.44)
//            make.size.equalTo(s)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.width.equalTo(200)
            make.height.equalTo(133)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imv.snp.bottom)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            
        }
        subLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(72)
            make.right.equalToSuperview().offset(-72)
            
        }
    }
}
