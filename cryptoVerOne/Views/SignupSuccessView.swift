//
//  SignupSuccessView.swift
//  betlead
//
//  Created by Victor on 2019/6/4.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum SuccessViewAction {
    case toMainView(String, String)
    case toPersonal(String, String)
    case toBet(String, String)
    case clickAD(acc: String, pwd: String, url: String)
    case member
    case wallet
    
    enum Route {
        case main
        case personal
        case bet
        case clickAD(url: String)
        case member
        case wallet
    }
    
    var route:Route {
        switch self {
        case .toMainView(_, _):
            return .main
        case .toPersonal(_, _):
            return .personal
        case .toBet(_, _):
            return .bet
        case .clickAD(let acc, let pwd, let url):
            return .clickAD(url: url)
        case .member:
            return .member
        case .wallet:
            return .wallet
        }
    }
}


class SignupSuccessView: UIView {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var successBgImv: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accountContentView: UIStackView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottonBannerImv: UIImageView!
    var account = "--------"
    var password = "--------"
    private var bannerDto: BannerDto? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        fetchBanner()
    }
    func fetchBanner() {
        let emptyUrl = "https://gss0.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/c9fcc3cec3fdfc03b7614cfed93f8794a4c2265e.jpg"
//        Beans.bannerServer.frontendBanner(banner_group: 4)
//            .subscribeSuccess { [weak self](response) in
//                guard let bannerDto = response.0.first else { return }
//                self?.bannerDto = bannerDto
//                let imgUrlString = bannerDto.bannerImageMobile.isEmpty ? emptyUrl : bannerDto.bannerImageMobile
//                DispatchQueue.main.async {
//                    self?.bottonBannerImv.sdLoad(with: URL(string:imgUrlString))
//                }
//            }.disposed(by: dpg)
    }
    
    // MARK: - rx
    private var onClick = PublishSubject<SuccessViewAction>()
    private let dpg = DisposeBag()
    
    func rxSuccessViewDidPressed() -> Observable<SuccessViewAction> {
        return onClick.asObserver()
    }
    
    @IBAction func bannerPressed(_ sender: UITapGestureRecognizer) {
        print("banner did tap")
        guard let dto = bannerDto else { return }
        let linkUrlStr = dto.bannerLinkMobile ?? "is empty"
        print("banner link url : \(linkUrlStr)")
        onClick.onNext(.clickAD(acc: account, pwd: password, url: linkUrlStr))
    }
    
    func binding(showAccount: Bool) {
        dismissButton.rx.tap.subscribeSuccess { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.onClick.onNext(.toMainView(strongSelf.account, strongSelf.password))
            }.disposed(by: dpg)
        
        doneButton.rx.tap.subscribeSuccess { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.onClick.onNext(
                showAccount ?
                    .toPersonal(strongSelf.account, strongSelf.password) :
                    .toMainView(strongSelf.account, strongSelf.password))
            }.disposed(by: dpg)
        
    }
    
    // MARK: - ui
    func setup(title: String, buttonTitle: String, showAccount: Bool) {
        
        let baseHeight: CGFloat = 812.0
        successBgImv.contentMode = Views.isIPhoneWithNotch() ? .scaleAspectFit : .scaleToFill
        titleLabel.text = title
        accountLabel.text = account
        passwordLabel.text = password
        doneButton.setTitle(buttonTitle, for: .normal)
        
        headlineLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(topOffset(30 / baseHeight))
            make.height.equalTo(14)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(headlineLabel)
            make.top.equalTo(headlineLabel.snp.bottom).offset(topOffset(20 / baseHeight))
            make.height.equalToSuperview().multipliedBy(0.07)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(headlineLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(topOffset(12 / baseHeight))
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        accountContentView.addBackground(color: Themes.grayLightest)
        accountContentView.snp.makeConstraints { (make) in
            make.centerX.equalTo(headlineLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(topOffset(20 / baseHeight))
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        accountContentView.isHidden = !showAccount
        tipLabel.isHidden = showAccount
        
        doneButton.layer.cornerRadius = Views.screenHeight * 0.05 / 2
        doneButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(headlineLabel)
            make.top.equalTo(showAccount ? accountContentView.snp.bottom: tipLabel.snp.bottom).offset(topOffset(12 / baseHeight))
            make.width.equalToSuperview().multipliedBy(0.42)
            make.height.equalTo(Views.screenHeight * 0.05)
        }
        bottonBannerImv.layer.cornerRadius = 8
        bottonBannerImv.clipsToBounds = true
        bottonBannerImv.snp.makeConstraints { (make) in
            make.centerX.equalTo(headlineLabel)
            make.top.equalTo(doneButton.snp.bottom).offset(topOffset(20 / baseHeight))
            make.height.equalToSuperview().multipliedBy(0.216)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        binding(showAccount:showAccount)
    }
    
}


