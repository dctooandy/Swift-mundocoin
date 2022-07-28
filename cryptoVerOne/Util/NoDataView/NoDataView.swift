//
//  NoDataView.swift
//  cryptoVerOne
//
//  Created by BBk on 6/8/22.
//

import UIKit
import RxSwift
import RxCocoa

class NoDataView: UIView {
    // MARK:業務設定
    private let onImageClick = PublishSubject<Void>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    private let imv: UIImageView = UIImageView()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.PlusJakartaSansBold(18)
        lb.textColor = Themes.gray2B3674
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    private let subLabel: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.PlusJakartaSansRegular(14)
        lb.textColor = Themes.grayA3AED0
        lb.numberOfLines = 0
        lb.textAlignment = .center
        return lb
    }()
    // MARK: -
    // MARK:Life cycle
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
        bindImage()
    }
    // MARK: -
    // MARK:業務方法
    private func setup() {
        addSubview(imv)
        addSubview(titleLabel)
        addSubview(subLabel)
        imv.contentMode = .scaleAspectFill
        imv.snp.makeConstraints { (make) in
//            let s = sizeFrom(scale: 0.44)
//            make.size.equalTo(s)
            make.centerX.equalToSuperview()
#if Approval_PRO || Approval_DEV || Approval_STAGE
            make.top.equalToSuperview().offset(50)
            make.width.equalTo(130)
            make.height.equalTo(126)

#else
            make.top.equalToSuperview().offset(83)
            make.width.equalTo(130)
            make.height.equalTo(86.3)
#endif
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imv.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            
        }
        subLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(72)
            make.right.equalToSuperview().offset(-72)
            
        }
    }
    func bindImage()
    {
        imv.rx.click.subscribeSuccess { [self] _ in
            onImageClick.onNext(())
        }.disposed(by: dpg)
    }
    func rxImageClick() -> Observable<Void>
    {
        return onImageClick.asObservable()
    }
}
