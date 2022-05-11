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
    @IBOutlet weak var registerButton: CornerradiusButton!
    @IBOutlet weak var bottomMessageLabel: UILabel!
    private var checkboxView: CheckBoxView!
    private var accountInputView: AccountInputView?
    private var timer: Timer? = nil
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
//    var rxVerifyCodeButtonClick: Observable<String>?
    private var onClick = PublishSubject<SignupPostDto>()
    
    private var loginMode : LoginMode = .account {
        didSet {
            loginModeDidChange()
        }
    }
    static func instance(mode: LoginMode) -> SignupViewController {
        let vc = SignupViewController.loadNib()
        vc.loginMode = mode
        return vc
    }
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindRegisterBtn()
        bindAccountView()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - UI
    func setDefault() {
        stopTimer()
        accountInputView?.passwordInputView.displayRightButton.setTitle("发送验证码", for: .normal)
    }
    
    func cleanTextField() {
        accountInputView?.cleanTextField()
    }
    
    private func setupUI() {
        
        accountInputView = AccountInputView(inputMode: loginMode, currentShowMode: .signup, lineColor: Themes.grayLight)
//        rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
        checkboxView = CheckBoxView(title: " ",
                                    titleColor: .black,
                                    checkBoxSize: 24,
                                    checkBoxColor: .black)

        view.addSubview(accountInputView!)
        view.addSubview(checkboxView)
//        accountInputView?.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(88)
//            make.centerX.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.872)
//            make.height.equalToSuperview().multipliedBy(0.275)
//        }
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(56)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(height(270/812))
        }
        bottomMessageLabel.snp.makeConstraints { make in
            make.leading.equalTo(accountInputView!).offset(48)
            make.trailing.equalTo(accountInputView!)
            make.top.equalTo(accountInputView!.snp.bottom).offset(15)
            make.height.equalTo(48)
        }

        checkboxView.snp.makeConstraints { make in
            make.leading.equalTo(accountInputView!).offset(20)
            make.centerY.equalTo(bottomMessageLabel!)
            make.height.equalTo(24)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.bottomMessageLabel!.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(view).multipliedBy(0.08)
        }
        registerButton.setTitle("Get Started".localized, for: .normal)
    }
    
    func modeTitle() -> String {
        switch  loginMode {
        case .account: return "".localized
        case .phone: return "Mobile".localized
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
        registerButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        registerButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
    }
    
    func signup() {
        guard let acc = accountInputView?.accountInputView.textField.text?.lowercased() else { return }
        guard let pwd = accountInputView?.passwordInputView.textField.text else { return }
        let dto = SignupPostDto(account: acc, password: pwd, signupMode: loginMode)
        self.view.endEditing(true)
        onClick.onNext(dto)
    }
    
    func rxSignupButtonPressed() -> Observable<SignupPostDto> {
        return onClick.asObserver()
    }
  
    private func loginModeDidChange() {
        accountInputView?.changeInputMode(mode: self.loginMode)
    }
    
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
}


