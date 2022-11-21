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
    private var accountInputView: AccountInputView!
    // MARK: -
    // MARK:Life cycle
    static func instance(mode: LoginMode) -> SignupViewController {
        let vc = SignupViewController.loadNib()
        vc.loginMode = mode
        vc.secondViewDidLoad()
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkboxView.isSelected = true
    }
    func secondViewDidLoad()
    {
        setupUI()
        bindRegisterBtn()
        bindAccountView()
        accountInputView?.bindTextfield()
        addKeyboardAction()
    }
    func addKeyboardAction()
    {
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
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            // 0920 註冊取消驗證碼輸入
            if KeychainManager.share.getRegistrationMode() == true
            {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                if ((accountInputView.registrationInputView.textField.isFirstResponder) == true)
                {
                    let diffHeight = view.frame.height - (accountInputView.frame.maxY)
                    if diffHeight < (keyboardHeight + 50)
                    {
                        let upHeight = (keyboardHeight + 50) - diffHeight
                        view.frame.origin.y = Views.navigationBarHeight - upHeight
                    }
                }
            }else
            {
                
            }
        }
//        if ((accountInputView?.registrationInputView.textField.isFirstResponder) == true)
//        {
//            var info = notification.userInfo!
//            let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//            self.view.frame.origin.y = 0 - keyboardSize!.height
//        }
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
        accountInputView.passwordInputView.displayRightButton.setTitle("发送验证码", for: .normal)
    }
    
    func cleanTextField() {
        accountInputView.cleanTextField()
    }
    
    private func setupUI() {
        
        switch loginMode {
        case .emailPage:
            accountInputView = AccountInputView(inputMode: loginMode.inputViewMode,
                                                currentShowMode: .signupEmail,
                                                lineColor: Themes.grayLight)
        case .phonePage:
            accountInputView = AccountInputView(inputMode: loginMode.inputViewMode,
                                                currentShowMode: .signupPhone,
                                                lineColor: Themes.grayLight)
        }
        
//        rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
//        checkboxView = CheckBoxView(title: " ",
//                                    titleColor: .black,
//                                    checkBoxSize: 24,
//                                    checkBoxColor: .black)
        checkboxView = CheckBoxView(type: .checkType)
        
        view.addSubview(accountInputView)
        view.addSubview(checkboxView)
//        accountInputView?.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(88)
//            make.centerX.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.872)
//            make.height.equalToSuperview().multipliedBy(0.275)
//        }
        accountInputView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(Themes.inputViewDefaultHeight + Themes.inputViewPasswordHeight + Themes.inputViewDefaultHeight) 
        }
        bottomMessageLabel.snp.makeConstraints { make in
            make.leading.equalTo(accountInputView).offset(60)
            make.trailing.equalTo(accountInputView).offset(-28)
            // 0920 註冊取消驗證碼輸入
            if KeychainManager.share.getRegistrationMode() == true
            {
                make.top.equalTo(accountInputView.registrationInputView.textField.snp.bottom).offset(8)
            }else
            {
                make.top.equalTo(accountInputView.passwordInputView.textField.snp.bottom).offset(36)
            }
            make.height.equalTo(48)
        }

        checkboxView.snp.makeConstraints { make in
            make.leading.equalTo(accountInputView).offset(32)
            make.top.equalTo(bottomMessageLabel!).offset(5)
            make.height.width.equalTo(20)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.bottomMessageLabel!.snp.bottom).offset(46)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        registerButton.setTitle("Get Started".localized, for: .normal)
    }
    
    func modeTitle() -> String {
        switch  loginMode {
        case .emailPage: return "E-mail".localized
        case .phonePage: return "Mobile".localized
        }
    }
    
    func showVerifyCode(_ code: String) {
        self.accountInputView.passwordInputView.textField.text = code
        self.accountInputView.passwordInputView.textField.sendActions(for: .valueChanged)
    }
   
    // MARK: - Actions
    func bindAccountView() {
        Observable.combineLatest(accountInputView.rxCheckPassed(),
                                 checkboxView.rxCheckBoxPassed())
            .map {
                return $0.0 && $0.1
                
            } //reget match result
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    
    func bindRegisterBtn() {
        registerButton.rx.tap.subscribeSuccess { [weak self] in
            self?.accountInputView.resignAllResponder()
            self?.verificationID()
        }.disposed(by: disposeBag)
    }
    func verificationID()
    {
        guard let account = accountInputView.accountInputView.textField.text?.lowercased() else {return}

        Beans.loginServer.verificationIDGet(idString: account).subscribe { [self] stringValue in
            Log.v("帳號沒註冊過")
            signup()
        } onError: { [self] error in
            if let error = error as? ApiServiceError {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    if status == "400"
                    {
                        if reason == "ID_NOT_EXISTS"
                        {
                            accountInputView.accountInputView.changeInvalidLabelAndMaskBorderColor(with: "Email already registered.")
                            InputViewStyleThemes.share.accountAcceptInputHeightStyle(.accountInvalidShow)
                        }  
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
    func signup() {
        resetInputView()
        // 登入動作
        signupActions()
    }
    func resetInputView()
    {
        // 重置輸入框的動作
        accountInputView.resetTFMaskView()
    }
    func signupActions()
    {
        guard let acc = accountInputView.accountInputView.textField.text?.lowercased() else { return }
        guard let pwd = accountInputView.passwordInputView.textField.text else { return }
        // 0920 註冊取消驗證碼輸入
        if KeychainManager.share.getRegistrationMode() == true
        {
            guard let regis = accountInputView.registrationInputView.textField.text , !regis.isEmpty else { return }
            if regis != "220831"
            {
                let error = ApiServiceError.unknownError(0,"Error","Registration Code Not Found")
                ErrorHandler.show(error: error)
            }else
            {
                var emailAccountString = ""
                var phoneAccountString = ""
                if loginMode == .emailPage
                {
                    emailAccountString = acc
                }else
                {
                    phoneAccountString = acc
                }
                let dto = SignupPostDto(account: emailAccountString,
                                        password: pwd,
                                        registration: regis ,
                                        signupMode: loginMode,
                                        phone: phoneAccountString)
                self.view.endEditing(true)
                onSignupAction.onNext(dto)
            }
        }else
        {
            var emailAccountString = ""
            var phoneAccountString = ""
            if loginMode == .emailPage
            {
                emailAccountString = acc
            }else
            {
                phoneAccountString = acc
            }
            let dto = SignupPostDto(account: emailAccountString,
                                    password: pwd,
                                    registration: "220831" ,
                                    signupMode: loginMode,
                                    phone: phoneAccountString)
            self.view.endEditing(true)
            onSignupAction.onNext(dto)            
        }
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
        accountInputView.changeInvalidTextColor(with: dtos)
    }
}


