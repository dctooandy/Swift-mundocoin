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
    private var inputMode: InputViewMode = .email
    private var currentShowMode: ShowMode = .loginEmail
    private let dpg = DisposeBag()
    private let accountCheckPassed = PublishSubject<Bool>()
    var acHeightConstraint : NSLayoutConstraint!
    var pwHeightConstraint : NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    var accountInputView : InputStyleView!
    var passwordInputView : InputStyleView!
    var registrationInputView : InputStyleView!
   
    // MARK: -
    // MARK:Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    convenience init(inputMode: InputViewMode, currentShowMode: ShowMode, lineColor: UIColor) {
        self.init(frame: .zero)
        self.inputMode = inputMode
        self.currentShowMode = currentShowMode
        self.lineColor = lineColor
        self.setup()
        self.bindStyle()
        self.bindBorderColor()
//        self.bindTextfield()
        self.bindCancelButton()
    }
    
    // MARK: -
    // MARK:業務方法
    func bindStyle()
    {
//        Themes.chooseOrNotChoose.bind(to: accountInputView.tfMaskView.rx.borderColor).disposed(by: dpg)
//        Themes.chooseOrNotChoose.bind(to: passwordInputView.tfMaskView.rx.borderColor).disposed(by: dpg)
//        Themes.chooseOrNotChoose.bind(to: registrationInputView.tfMaskView.rx.borderColor).disposed(by: dpg)
        InputViewStyleThemes.pwInputHeightType.bind(to: pwHeightConstraint.rx.constant).disposed(by: dpg)
    }
    func bindTextfield() {
        let isAccountValid = accountInputView.textField.rx.text
//        let isAccountValid = accountTextField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false  }
                if strongSelf.inputMode == .phone{
                    return RegexHelper.match(pattern:. phone, input: acc)
                }
                return RegexHelper.match(pattern: .mail, input: acc)
        }
        
        let isPasswordValid = passwordInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false }
                if ((self?.passwordInputView.textField.isFirstResponder) == true) {
                    if strongSelf.inputMode == .phone {
                        return RegexHelper.match(pattern: .password, input: acc) || acc.isEmpty == true
                    }
                    return RegexHelper.match(pattern: .password, input: acc) || acc.isEmpty == true
                }else
                {
                    return true
                }
        }
        let isPasswordHeightType = passwordInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let acc = str else { return .invalidHidden }
                if ((self?.passwordInputView.textField.isFirstResponder) == true) {
                    if strongSelf.inputMode == .phone {
                        return RegexHelper.match(pattern: .password, input: acc) == true ? .invalidHidden : (acc.isEmpty == true ? .invalidHidden : .pwInvalidShow)
                    }
                    return RegexHelper.match(pattern: .password, input: acc) == true ? .invalidHidden : (acc.isEmpty == true ? .invalidHidden : .pwInvalidShow)
                }else
                {
                    return .invalidHidden
                }
        }
        isPasswordHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
        let isRegistrationValid = registrationInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        isAccountValid.skip(1).bind(to: accountInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        
        if currentShowMode == .forgotPW
        {
            isAccountValid.bind(to: accountCheckPassed).disposed(by: dpg)
        }else if currentShowMode == .signupEmail ||
                    currentShowMode == .signupPhone
        {
            isPasswordValid.bind(to: passwordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
           
//            isRegistrationValid.skip(1).bind(to: registrationInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//            isPasswordValid.skip(1).bind(to: passwordInvalidLabel.rx.isHidden).disposed(by: dpg)
            Observable.combineLatest(isAccountValid, isPasswordValid , isRegistrationValid)
                .map {
                    return $0.0 && $0.1 && $0.2
                    
                } //reget match result
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
//        let _ =  accountInputView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: accountInputView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
//        let _ = passwordInputView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: passwordInputView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
//        let _ = registrationInputView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: registrationInputView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
    }
    
    func bindBorderColor()
    {
        accountInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText()
            resetTFMaskView(account:isChoose)
            resetInputView(view: passwordInputView)
//            accountInputView.textField.sendActions(for: .valueChanged)
            InputViewStyleThemes.share.acceptInputHeightStyle(.invalidHidden)
        }.disposed(by: dpg)
        passwordInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText()
            resetTFMaskView(password:isChoose)
            resetInputView(view: accountInputView)
//            passwordInputView.textField.sendActions(for: .valueChanged)
        }.disposed(by: dpg)
        registrationInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText()
            resetTFMaskView(regis:isChoose)
            registrationInputView.invalidLabel.isHidden = true
        }.disposed(by: dpg)
    }
    func resetInvalidText()
    {
        accountInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        passwordInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        registrationInputView.changeInvalidLabelAndMaskBorderColor(with:"")
    }
    func resetTFMaskView(account:Bool = false ,password:Bool = false ,regis:Bool = false )
    {
        accountInputView.tfMaskView.changeBorderWith(isChoose:account)
        passwordInputView.tfMaskView.changeBorderWith(isChoose:password)
        registrationInputView.tfMaskView.changeBorderWith(isChoose:regis)
    }
    func resetInputView(view : InputStyleView)
    {
        view.invalidLabel.isHidden = true
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
        let accountView = InputStyleView(inputViewMode: currentShowMode.accountInputMode)
        let passwordView = InputStyleView(inputViewMode: .password)
        let registrationView = InputStyleView(inputViewMode: .registration)
        self.accountInputView = accountView
        self.passwordInputView = passwordView
        self.registrationInputView = registrationView
        addSubview(accountInputView)
        accountInputView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewDefaultHeight)
        }
        pwHeightConstraint = NSLayoutConstraint(item: passwordInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: Themes.inputViewPasswordHeight)
        
        switch currentShowMode {
        case .loginEmail , .loginPhone:
            addSubview(passwordInputView)
            passwordInputView.snp.makeConstraints { (make) in
                make.top.equalTo(accountInputView.snp.bottom)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(pwHeightConstraint.constant)
//                make.height.equalTo(Themes.inputViewPasswordHeight)
            }
            passwordInputView.addConstraint(pwHeightConstraint)
        case .signupEmail , .signupPhone:
            addSubview(passwordInputView)
            addSubview(registrationInputView)
            passwordInputView.snp.makeConstraints { (make) in
                make.top.equalTo(accountInputView.snp.bottom)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(pwHeightConstraint.constant)
//                make.height.equalTo(Themes.inputViewPasswordHeight)
            }
            passwordInputView.addConstraint(pwHeightConstraint)
            registrationInputView.snp.makeConstraints { (make) in
                make.top.equalTo(passwordInputView.snp.bottom)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(Themes.inputViewDefaultHeight)
            }
        case .forgotPW:
            break
        }
    }
    func changeInvalidTextColor(with invalidDto:[ErrorsDetailDto])
    {
        for subData in invalidDto
        {
            if accountInputView.textField.text?.lowercased() == subData.rejectValue.lowercased()
            {
                accountInputView.changeInvalidLabelAndMaskBorderColor(with: subData.reason)
            }
            if passwordInputView.textField.text?.lowercased() == subData.rejectValue.lowercased()
            {
                passwordInputView.changeInvalidLabelAndMaskBorderColor(with: subData.reason)
            }
            if registrationInputView.textField.text?.lowercased() == subData.rejectValue.lowercased()
            {
                registrationInputView.changeInvalidLabelAndMaskBorderColor(with: subData.reason)
            }
        }
    }
//    func changeInputMode(mode: LoginMode) {
//        inputMode = mode
//        accountInputView.resetUI()
//        passwordInputView.resetUI()
//        registrationInputView.resetUI()
//    }
}
