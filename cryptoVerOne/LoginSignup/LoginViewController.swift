//
//  LoginViewController.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: BaseViewController {

    @IBOutlet weak private var forgetPasswordButton: UIButton!
    @IBOutlet weak var loginButton: CornerradiusButton!
    private var accountInputView: AccountInputView?
    
    private var timer: Timer?
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    private var onClickLogin = PublishSubject<LoginPostDto>()
//    var rxVerifyCodeButtonClick: Observable<String>?
    private var loginMode : LoginMode = .emailPage {
        didSet {
//            self.loginModeDidChange()
        }
    }
    // MARK: instance
    static func instance(mode: LoginMode) -> LoginViewController {
        let vc = LoginViewController.loadNib()
        vc.loginMode = mode
        return vc
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindLoginBtn()
        bindAccountView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - UI
    
    func setDefault() {
        stopTimer()
        accountInputView?.passwordInputView.displayRightButton.setTitle("", for: .normal)
    }
    
    func cleanTextField() {
        self.accountInputView?.cleanTextField()
    }
    
    func setAccount(acc: String, pwd: String) {
        DispatchQueue.main.async { [weak self] in
            self?.accountInputView?.accountInputView.textField.text = acc
            self?.accountInputView?.passwordInputView.textField.text = pwd
            self?.accountInputView?.passwordInputView.textField.sendActions(for: .valueChanged)
        }
    }
    func modeTitle() -> String {
        switch  loginMode {
        case .emailPage: return "".localized
        case .phonepPage: return "Mobile".localized
        }
    }
    
    func setup() {
        
        accountInputView = AccountInputView(inputMode: loginMode.inputViewMode, currentShowMode: .loginEmail, lineColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
//        self.rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
        view.addSubview(accountInputView!)
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(180)
        }
        view.addSubview(forgetPasswordButton)
        view.addSubview(loginButton)
        forgetPasswordButton.titleLabel?.font = Fonts.pingFangTCRegular(16)
        forgetPasswordButton.snp.makeConstraints { (make) in
            make.left.equalTo(accountInputView!).offset(20)
            make.top.equalTo(accountInputView!.snp.bottom).offset(20)
            make.height.equalTo(18)
        }
        
        loginButton.titleLabel?.font = Fonts.pingFangTCRegular(16)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.forgetPasswordButton.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(view).multipliedBy(0.08)
        }
        // set default login mode
//        loginModeDidChange()
        forgetPasswordButton.isHidden = loginMode == .phonepPage
        forgetPasswordButton.setTitle("Forgot Password?".localized, for: .normal)
        loginButton.setTitle("Log In".localized, for: .normal)
        
    }
    
    func showVerifyCode(_ code: String) {
        self.accountInputView?.passwordInputView.textField.text = code
        self.accountInputView?.passwordInputView.textField.sendActions(for: .valueChanged)
    }
    
    //MARK: Actions
    func bindAccountView() {
        accountInputView!.rxCheckPassed()
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func bindLoginBtn() {
        loginButton.rx.tap.subscribeSuccess { [weak self] _ in
                self?.login()
            }.disposed(by: disposeBag)
        loginButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        loginButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
    }
    
    private func login() {
        
        guard let account = accountInputView?.accountInputView.textField.text?.lowercased() else {return}
        guard let password = accountInputView?.passwordInputView.textField.text else {return}
        let dto = LoginPostDto(account: account, password: password,loginMode: self.loginMode ,showMode: .loginEmail)
        self.onClickLogin.onNext(dto)
        
    }
    
    func startReciprocal() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPwdRightBtnSecondTime), userInfo: nil, repeats: true)
//        self.accountInputView?.setPasswordRightBtnEnable(isEnable: false)
    }
    
    @objc private func setPwdRightBtnSecondTime() {
        
//        self.accountInputView?.setPasswordRightBtnTime(seconds)
        if seconds == 0 {
            stopTimer()
            return
        }
        seconds -= 1
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
        seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
//        self.accountInputView?.setPasswordRightBtnEnable(isEnable: true)
    }
    
    func rxForgetPassword() -> ControlEvent<Void> {
        return forgetPasswordButton.rx.tap
    }
    
    func rxLoginButtonPressed() -> Observable<LoginPostDto> {
        return onClickLogin.asObserver()
    }

    
//    private func loginModeDidChange() {
//        accountInputView?.changeInputMode(mode: loginMode)
//    }
}


