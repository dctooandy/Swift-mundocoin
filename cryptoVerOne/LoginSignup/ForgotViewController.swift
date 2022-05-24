//
//  ForgotViewController.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ForgotViewController: BaseViewController {
    // MARK:業務設定
    private var timer: Timer?
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    private var onClickLogin = PublishSubject<LoginPostDto>()
//    var rxVerifyCodeButtonClick: Observable<String>?
    private var loginMode : LoginMode = .emailPage {
        didSet {
//            self.loginModeDidChange()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var sendResetLinkButton: CornerradiusButton!
    private var accountInputView: AccountInputView?
    // MARK: -
    // MARK:Life cycle
    static func instance(mode: LoginMode) -> ForgotViewController {
        let vc = ForgotViewController.loadNib()
        vc.loginMode = mode
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindLinkBtn()
        bindAccountView()
    }
    // MARK: -
    // MARK:業務方法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setDefault() {
//        stopTimer()
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
        switch loginMode {
        case .emailPage: return "".localized
        case .phonepPage: return "Mobile".localized
        }
    }
    
    func setup() {
        
        accountInputView = AccountInputView(inputMode: loginMode.inputViewMode, currentShowMode: .forgotPW, lineColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
//        self.rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
        view.addSubview(accountInputView!)
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(56)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(Themes.inputViewDefaultHeight)
        }
        view.addSubview(sendResetLinkButton)
        
        sendResetLinkButton.snp.makeConstraints { (make) in
            make.top.equalTo(accountInputView!.snp.bottom).offset(65)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        // set default login mode
        loginModeDidChange()
        sendResetLinkButton.setTitle("Send".localized, for: .normal)
        
    }
    
    func showVerifyCode(_ code: String) {
        self.accountInputView?.passwordInputView.textField.text = code
        self.accountInputView?.passwordInputView.textField.sendActions(for: .valueChanged)
    }
    
    //MARK: Actions
    func bindAccountView() {
        accountInputView!.rxCheckPassed()
            .bind(to: sendResetLinkButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func bindLinkBtn() {
        sendResetLinkButton.rx.tap.subscribeSuccess { [weak self] _ in
                self?.sendReset()
            }.disposed(by: disposeBag)
    }
    
    private func sendReset()
    {
        resetInputView()
        clickLoginActions()
    }
    func resetInputView()
    {
        accountInputView?.resetTFMaskView()
    }
    func clickLoginActions()
    {
        if let account = accountInputView?.accountInputView.textField.text
        {
            let dto = LoginPostDto(account: account, password:"",loginMode: self.loginMode ,showMode: .forgotPW)
            self.onClickLogin.onNext(dto)
        }
    }
//    func startReciprocal() {
//        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPwdRightBtnSecondTime), userInfo: nil, repeats: true)
//        self.accountInputView?.setPasswordRightBtnEnable(isEnable: false)
//    }
    
//    @objc private func setPwdRightBtnSecondTime() {
//
//        self.accountInputView?.setPasswordRightBtnTime(seconds)
//        if seconds == 0 {
//            stopTimer()
//            return
//        }
//        seconds -= 1
//    }
    
//    private func stopTimer() {
//        self.timer?.invalidate()
//        self.timer = nil
//        seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
//        self.accountInputView?.setPasswordRightBtnEnable(isEnable: true)
//    }
    
    
    func rxResetButtonPressed() -> Observable<LoginPostDto> {
        return onClickLogin.asObserver()
    }

    
    private func loginModeDidChange() {
//        accountInputView?.changeInputMode(mode: loginMode)
    }
    func changeInvalidTextWith(dtos:[ErrorsDetailDto])
    {
        accountInputView?.changeInvalidTextColor(with: dtos)
    }
}


