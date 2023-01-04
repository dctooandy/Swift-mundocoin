//
//  NoBalanceView.swift
//  cryptoVerOne
//
//  Created by BBk on 7/25/22.
//


import UIKit
import RxSwift
import RxCocoa

class NoBalanceView: UIView {
    // MARK:業務設定
    private let onImageClick = PublishSubject<Void>()
    private let onGoDepositAction = PublishSubject<Void>()
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
    let goDepositLabel: UILabel = {
       let lb = UILabel()
       lb.font = Fonts.PlusJakartaSansBold(14)
        lb.text = "Let’s Deposit"
       lb.numberOfLines = 0
       lb.textAlignment = .center
       lb.textColor = Themes.blue6149F6
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
    
    init(image: UIImage?, title: String , subTitle:String , forAddressBook : Bool = false) {
        super.init(frame: .zero)
        imv.image = image
        titleLabel.text = title
        subLabel.text = subTitle
        setup(forAddressBook: forAddressBook)
        bindLabel()
    }
    // MARK: -
    // MARK:業務方法
    private func setup(forAddressBook : Bool = false) {
        addSubview(imv)
        addSubview(titleLabel)
        addSubview(subLabel)
        addSubview(goDepositLabel)
        imv.contentMode = .scaleAspectFill
        imv.snp.makeConstraints { (make) in
//            let s = sizeFrom(scale: 0.44)
//            make.size.equalTo(s)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(forAddressBook ? 0 : 45)
            make.width.equalTo(forAddressBook ? 82:130)
            make.height.equalTo(forAddressBook ? 54:86)
        }
        if forAddressBook
        {
            titleLabel.font = Fonts.PlusJakartaSansRegular(12)
            titleLabel.textColor = Themes.grayA3AED0
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imv.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            
        }
        subLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(72)
            make.right.equalToSuperview().offset(-72)
        }
        goDepositLabel.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
    }

    func bindLabel()
    {
        goDepositLabel.rx.click.subscribeSuccess { [self] _ in
            onGoDepositAction.onNext(())
        }.disposed(by: dpg)
    }
    
    func rxLabelClick() -> Observable<Void>
    {
        return onGoDepositAction.asObservable()
    }
}
