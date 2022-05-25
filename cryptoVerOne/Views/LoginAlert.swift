//
//  LoginAlert.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import UIKit

class LoginAlert:BaseViewController {
    
    private let container = UIView(color: .white)
    private lazy var bgView : UIView = {
       let view = UIView(color: UIColor.black.withAlphaComponent(0.5))
        let tap = UITapGestureRecognizer(target: self, action: #selector(dissmissVC))
        view.addGestureRecognizer(tap)
        return view
    }()
    private let topBgView = UIView()
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = "提示"
        label.textAlignment = .center
        return label
    }()
    private let hintLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = Themes.grayBase
        label.text = "请先登录倍利帐号"
        return label
    }()
    
    private let registerBtn:UIButton = {
        let btn = UIButton()
        btn.layer.borderColor = Themes.primaryBase.cgColor
        btn.layer.borderWidth = 1
        btn.setTitle("注册", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(Themes.primaryBase, for: .normal)
        btn.applyCornerRadius(radius: 20)
        return btn
    }()
    
    private let loginBtn:UIButton = {
        let btn = UIButton()
        btn.backgroundColor = Themes.primaryBase
        btn.setTitle("登录", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(.white, for: .normal)
        btn.applyCornerRadius(radius: 20)
        return btn
    }()
    
    
     init(){
        super.init()
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindBtns()
        
    }
    private func setupViews(){
        view.addSubview(bgView)
        view.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(hintLabel)
        container.addSubview(registerBtn)
        container.addSubview(loginBtn)
        bgView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
        container.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.leading.equalTo(20)
            maker.trailing.equalTo(-20)
            maker.height.equalTo(200)
        }
        titleLabel.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(56)
        }
        
        hintLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        registerBtn.snp.makeConstraints { (maker) in
            maker.leading.equalTo(18)
            maker.trailing.equalTo(container.snp_centerX).offset(-6)
            maker.height.equalTo(40)
            maker.top.equalTo(hintLabel.snp.bottom).offset(24)
        }
        loginBtn.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-18)
            maker.leading.equalTo(container.snp_centerX).offset(6)
            maker.height.equalTo(40)
            maker.top.equalTo(registerBtn)
        }
        view.layoutIfNeeded()
        container.applyCornerRadius(radius: 16)
        titleLabel.addGradientLayer(colors: [Themes.primaryBase.cgColor,Themes.primaryDark.cgColor], direction: .toRight)
    }
    private func bindBtns(){
        
        registerBtn.rx.tap.subscribeSuccess { (_) in
//            UIApplication.shared.keyWindow?.rootViewController = LoginSignupViewController.share.isLogin(false)
            let loginNavVC = MuLoginNavigationController(rootViewController: LoginSignupViewController.share.showMode(.signupEmail))
            UIApplication.shared.keyWindow?.rootViewController = loginNavVC
            }.disposed(by: disposeBag)
        
        loginBtn.rx.tap.subscribeSuccess { (_) in
//            UIApplication.shared.keyWindow?.rootViewController = LoginSignupViewController.share.isLogin(true)
            let loginNavVC = MuLoginNavigationController(rootViewController: LoginSignupViewController.share.showMode(.loginEmail))
            UIApplication.shared.keyWindow?.rootViewController = loginNavVC
            }.disposed(by: disposeBag)
    }
    
    @objc private func dissmissVC(){
        dismiss(animated: true, completion: nil)
    }
    
}
