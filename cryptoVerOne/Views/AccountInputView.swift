//
//  AccountInputView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import UIKit
import RxCocoa
import RxSwift

class AccountInputView: UIView {
    // MARK:業務設定
    private var lineColor: UIColor = .white
    private var inputMode: LoginMode = .account
    private var currentShowMode: ShowMode = .login
    private let dpg = DisposeBag()
    private let accountCheckPassed = BehaviorSubject(value: false)
    // MARK: -
    // MARK:UI 設定
    var accountInputView = InputStyleView()
    var passwordInputView = InputStyleView()
    var registrationInputView = InputStyleView()
   
    // MARK: -
    // MARK:Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    convenience init(inputMode: LoginMode, currentShowMode: ShowMode, lineColor: UIColor) {
        self.init(frame: .zero)
        self.inputMode = inputMode
        self.currentShowMode = currentShowMode
        self.lineColor = lineColor
        self.setup()
        self.bindTextfield()
        self.bindCancelButton()
    }
    
    // MARK: -
    // MARK:業務方法
    
    func bindTextfield() {
        let isAccountValid = accountInputView.textField.rx.text
//        let isAccountValid = accountTextField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false  }
                if strongSelf.inputMode == .phone {
                    return RegexHelper.match(pattern:. phone, input: acc)
                }
                return RegexHelper.match(pattern: .mail, input: acc)
        }
        let isPasswordValid = passwordInputView.textField.rx.text
//        let isPasswordValid = passwordTextField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false }
                if strongSelf.inputMode == .phone {
                    return RegexHelper.match(pattern: .password, input: acc)
                }
                return RegexHelper.match(pattern: .password, input: acc)
        }
        let isRegistrationValid = registrationInputView.textField.rx.text
//        let isPasswordValid = passwordTextField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false }
                return RegexHelper.match(pattern: .otp, input: acc)
                
        }
        isAccountValid.skip(1).bind(to: accountInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//        isAccountValid.skip(1).bind(to: accountInvalidLabel.rx.isHidden).disposed(by: dpg)
        
        if currentShowMode == .forgotPW
        {
            isAccountValid.bind(to: accountCheckPassed).disposed(by: dpg)
        }else if currentShowMode == .signup
        {
            isPasswordValid.skip(1).bind(to: passwordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
            isRegistrationValid.skip(1).bind(to: registrationInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//            isPasswordValid.skip(1).bind(to: passwordInvalidLabel.rx.isHidden).disposed(by: dpg)
            Observable.combineLatest(isAccountValid, isPasswordValid , isRegistrationValid)
                .map { return $0.0 && $0.1 && $0.2 } //reget match result
                .bind(to: accountCheckPassed)
                .disposed(by: dpg)
        }else
        {
            isPasswordValid.skip(1).bind(to: passwordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//            isPasswordValid.skip(1).bind(to: passwordInvalidLabel.rx.isHidden).disposed(by: dpg)
            Observable.combineLatest(isAccountValid, isPasswordValid)
                .map { return $0.0 && $0.1 } //reget match result
                .bind(to: accountCheckPassed)
                .disposed(by: dpg)
        }
    }
    func bindCancelButton()
    {
        let _ =  accountInputView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: accountInputView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
        let _ = passwordInputView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: passwordInputView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
        let _ = registrationInputView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: registrationInputView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
    }
    func rxCheckPassed() -> Observable<Bool> {
        return accountCheckPassed.asObserver()
    }
    
    func cleanTextField() {
        accountInputView.textField.text = ""
        passwordInputView.textField.text = ""
        registrationInputView.textField.text = ""
        accountInputView.textField.sendActions(for: .valueChanged)
        passwordInputView.textField.sendActions(for: .valueChanged)
        registrationInputView.textField.sendActions(for: .valueChanged)
        accountInputView.invalidLabel.isHidden = true
        passwordInputView.invalidLabel.isHidden = true
        registrationInputView.invalidLabel.isHidden = true
    }
    
    func setup() {
        let accountView = InputStyleView(inputMode: inputMode, currentShowMode: currentShowMode, isPWStyle: false)
        let passwordView = InputStyleView(inputMode: inputMode, currentShowMode: currentShowMode, isPWStyle: true)
        let registrationView = InputStyleView(inputMode: inputMode, currentShowMode: currentShowMode, isPWStyle: false,isRegisterStyle: true)
        self.accountInputView = accountView
        self.passwordInputView = passwordView
        self.registrationInputView = registrationView
        addSubview(accountInputView)
        accountInputView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(height(90/812))
        }
        switch currentShowMode {
        case .login:
            addSubview(passwordInputView)
            passwordInputView.snp.makeConstraints { (make) in
                make.top.equalTo(accountInputView.snp.bottom)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(height(90/812))
            }
        case .signup:
            addSubview(passwordInputView)
            addSubview(registrationInputView)
            passwordInputView.snp.makeConstraints { (make) in
                make.top.equalTo(accountInputView.snp.bottom)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(height(90/812))
            }
            registrationInputView.snp.makeConstraints { (make) in
                make.top.equalTo(passwordInputView.snp.bottom)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(height(90/812))
            }
        case .forgotPW:
            break

        }
    }
    
    func changeInputMode(mode: LoginMode) {
        inputMode = mode
        accountInputView.resetUI()
        passwordInputView.resetUI()
        registrationInputView.resetUI()
    }
}
