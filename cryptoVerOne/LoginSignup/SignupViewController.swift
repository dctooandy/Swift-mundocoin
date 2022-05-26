//
//  SignupViewController.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxSwift

class SignupViewController: BaseViewController {
    // MARK:業務設定
    private var timer: Timer? = nil
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    private var onSignupAction = PublishSubject<SignupPostDto>()
    var loginMode : LoginMode = .emailPage {
        didSet {
            //            loginModeDidChange()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var registerButton: CornerradiusButton!
    @IBOutlet weak var bottomMessageLabel: UILabel!
    private var checkboxView: CheckBoxView!
    private var accountInputView: AccountInputView?
    // MARK: -
    // MARK:Life cycle
    static func instance(mode: LoginMode) -> SignupViewController {
        let vc = SignupViewController.loadNib()
        vc.loginMode = mode
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindRegisterBtn()
        bindAccountView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    
    }
    @objc func keyboardWillShow(notification: NSNotification) {

        if ((accountInputView?.registrationInputView.textField.isFirstResponder) == true)
        {
            var info = notification.userInfo!
            let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            self.view.frame.origin.y = 0 - keyboardSize!.height
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        resetInputView()
    }
    
    // MARK: -
    // MARK:業務方法
    func setDefault() {
        stopTimer()
        accountInputView?.passwordInputView.displayRightButton.setTitle("发送验证码", for: .normal)
    }
    
    func cleanTextField() {
        accountInputView?.cleanTextField()
    }
    
    private func setupUI() {
        
        switch loginMode {
        case .emailPage:
            accountInputView = AccountInputView(inputMode: loginMode.inputViewMode, currentShowMode: .signupEmail, lineColor: Themes.grayLight)
        case .phonepPage:
            accountInputView = AccountInputView(inputMode: loginMode.inputViewMode, currentShowMode: .signupPhone, lineColor: Themes.grayLight)
        }
        
//        rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
//        checkboxView = CheckBoxView(title: " ",
//                                    titleColor: .black,
//                                    checkBoxSize: 24,
//                                    checkBoxColor: .black)
        checkboxView = CheckBoxView(type: .checkType)
        checkboxView.isSelected = true
        view.addSubview(accountInputView!)
        view.addSubview(checkboxView)
//        accountInputView?.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(88)
//            make.centerX.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.872)
//            make.height.equalToSuperview().multipliedBy(0.275)
//        }
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(Themes.inputViewDefaultHeight + Themes.inputViewPasswordHeight + Themes.inputViewDefaultHeight) 
        }
        bottomMessageLabel.snp.makeConstraints { make in
            make.leading.equalTo(accountInputView!).offset(48)
            make.trailing.equalTo(accountInputView!)
            make.top.equalTo(accountInputView!.snp.bottom)
            make.height.equalTo(48)
        }

        checkboxView.snp.makeConstraints { make in
            make.leading.equalTo(accountInputView!).offset(20)
            make.centerY.equalTo(bottomMessageLabel!)
            make.height.equalTo(24)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.bottomMessageLabel!.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        registerButton.setTitle("Get Started".localized, for: .normal)
    }
    
    func modeTitle() -> String {
        switch  loginMode {
        case .emailPage: return "".localized
        case .phonepPage: return "Mobile".localized
        }
    }
    
    func showVerifyCode(_ code: String) {
        self.accountInputView?.passwordInputView.textField.text = code
        self.accountInputView?.passwordInputView.textField.sendActions(for: .valueChanged)
    }
    // MARK: - Actions
    func bindAccountView() {
        Observable.combineLatest(accountInputView!.rxCheckPassed(),
                                 checkboxView.rxCheckBoxPassed())
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    
    func bindRegisterBtn() {
        registerButton.rx.tap.subscribeSuccess { [weak self] in
            self?.signup()
        }.disposed(by: disposeBag)
    }
    
    func signup() {
        resetInputView()
        // 登入動作
        signupActions()
    }
    func resetInputView()
    {
        // 重置輸入框的動作
        accountInputView?.resetTFMaskView()
    }
    func signupActions()
    {
        guard let acc = accountInputView?.accountInputView.textField.text?.lowercased() else { return }
        guard let pwd = accountInputView?.passwordInputView.textField.text else { return }
        guard let regis = accountInputView?.registrationInputView.textField.text else { return }
        let dto = SignupPostDto(account: acc, password: pwd,registration: regis, signupMode: loginMode)
        self.view.endEditing(true)
        onSignupAction.onNext(dto)
    }
    func rxSignupButtonPressed() -> Observable<SignupPostDto> {
        return onSignupAction.asObserver()
    }
  
//    private func loginModeDidChange() {
//        accountInputView?.changeInputMode(mode: self.loginMode)
//    }
    
    func startReciprocal() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPwdRightBtnSecondTime), userInfo: nil, repeats: true)
//        self.accountInputView?.setPasswordRightBtnEnable(isEnable: false)
        timer?.fire()
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
    func changeInvalidTextWith(dtos:[ErrorsDetailDto])
    {
        accountInputView?.changeInvalidTextColor(with: dtos)
    }
}


