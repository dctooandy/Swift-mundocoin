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
import Toaster

class LoginViewController: BaseViewController {
    // MARK:業務設定
    private var timer: Timer?
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    private var onClickLogin = PublishSubject<LoginPostDto>()
    private var onClickForgot = PublishSubject<Void>()
    private var loginMode : LoginMode = .emailPage {
        didSet {
//            self.loginModeDidChange()
        }
    }
    // MARK: -
    // MARK:UI 設定
    let forgetPasswordLabel: UnderlinedLabel = {
        let tfLabel = UnderlinedLabel()
        tfLabel.contentMode = .center
        tfLabel.backgroundColor = .clear
        tfLabel.font = Fonts.PlusJakartaSansBold(14)
        tfLabel.textColor = Themes.gray707EAE
        tfLabel.numberOfLines = 0
        tfLabel.adjustsFontSizeToFitWidth = true
        tfLabel.minimumScaleFactor = 0.8
        tfLabel.isUserInteractionEnabled = true
        tfLabel.isGrayColor = true
        tfLabel.text = "Forgot Password?".localized
        return tfLabel
    }()
    @IBOutlet weak private var forgetPasswordButton: UIButton!
    @IBOutlet weak var loginButton: CornerradiusButton!
    var accountInputView: AccountInputView?

    // MARK: -
    // MARK:Life cycle
    static func instance(mode: LoginMode) -> LoginViewController {
        let vc = LoginViewController.loadNib()
        vc.loginMode = mode
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindLoginBtn()
        bindAccountView()
        accountInputView?.bindTextfield()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let acView = accountInputView
        {
            acView.cleanTextField()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        resetInputView()
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
        case .phonePage: return "Mobile".localized
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
            make.height.equalTo(Themes.inputViewDefaultHeight + Themes.inputViewPasswordHeight)
        }
        view.addSubview(forgetPasswordLabel)
        view.addSubview(loginButton)
        
        forgetPasswordLabel.snp.makeConstraints { (make) in
            make.left.equalTo(accountInputView!).offset(32)
            make.top.equalTo(accountInputView!.passwordInputView.snp.bottom)
            make.height.equalTo(18)
        }

        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.forgetPasswordLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
#if Approval_PRO || Approval_DEV || Approval_STAGE
        forgetPasswordLabel.isHidden = true
#else
        forgetPasswordLabel.isHidden = loginMode == .phonePage
// 暫時先隱藏
//    forgetPasswordLabel.isHidden = true
#endif
        forgetPasswordLabel.rx.click.subscribeSuccess { [self] _ in
            onClickForgot.onNext(())
        }.disposed(by: disposeBag)
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
        loginButton.rx.tap.subscribeSuccess { [self] _ in
            loginButton.isEnabled = false
#if Approval_PRO || Approval_DEV || Approval_STAGE
            Log.v("帳號不驗證")
            login()
#else
            verificationID()
#endif
            
            }.disposed(by: disposeBag)
    }
    func verificationID()
    {
        guard let account = accountInputView?.accountInputView.textField.text?.lowercased() else {return}
        guard let pwString = accountInputView?.passwordInputView.textField.text else {return}
        Beans.loginServer.verificationIDPost(idString: account , pwString: pwString).subscribe { [self] dto in
            Log.v("帳號有註冊過")
            login()
        } onError: { [self] error in
            if let error = error as? ApiServiceError {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    
                    if status == "400"
                    {
                        accountInputView?.passwordInputView.changeInvalidLabelAndMaskBorderColor(with: reason)
                        InputViewStyleThemes.share.acceptInputHeightStyle(.pwInvalidShow)
                    }else if status == "404"
                    {
                        accountInputView?.accountInputView.changeInvalidLabelAndMaskBorderColor(with: reason)
                        InputViewStyleThemes.share.acceptInputHeightStyle(.normalInvalidShow)
                    }else
                    {
                        ErrorHandler.show(error: error)
                    }
                default:
                    ErrorHandler.show(error: error)
                }
            }
        }.disposed(by: disposeBag)

    }
    private func login() {
        resetInputView()
        loginActions()
    }
    func resetInputView()
    {
        accountInputView?.resetTFMaskView()
    }
    func loginActions()
    {
        guard let account = accountInputView?.accountInputView.textField.text?.lowercased() else {return}
        guard let password = accountInputView?.passwordInputView.textField.text else {return}
        let dto = LoginPostDto(account: account, password: password,loginMode: self.loginMode ,showMode: .loginEmail)
        // 登入成功後
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
    
    func rxForgetPassword() -> Observable<Void> {
        return onClickForgot.asObserver()
    }
    func rxLoginButtonPressed() -> Observable<LoginPostDto> {
        return onClickLogin.asObserver()
    }

    
//    private func loginModeDidChange() {
//        accountInputView?.changeInputMode(mode: loginMode)
//    }
    func changeInvalidTextWith(dtos:[ErrorsDetailDto])
    {
        accountInputView?.changeInvalidTextColor(with: dtos)
    }
}


