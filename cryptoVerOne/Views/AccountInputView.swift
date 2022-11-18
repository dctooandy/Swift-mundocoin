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
    private let chooseAreaPassed = PublishSubject<String>()
    var acHeightConstraint : NSLayoutConstraint!
    var pwHeightConstraint : NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    var accountInputView : InputStyleView!
    var passwordInputView : InputStyleView!
    // 0920 註冊取消驗證碼輸入
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
        self.bindTextfieldReturnKey()
    }
    
    // MARK: -
    // MARK:業務方法
    func bindStyle()
    {
//        Themes.chooseOrNotChoose.bind(to: accountInputView.tfMaskView.rx.borderColor).disposed(by: dpg)
//        Themes.chooseOrNotChoose.bind(to: passwordInputView.tfMaskView.rx.borderColor).disposed(by: dpg)
//        Themes.chooseOrNotChoose.bind(to: registrationInputView.tfMaskView.rx.borderColor).disposed(by: dpg)
        InputViewStyleThemes.normalInputHeightType.bind(to: acHeightConstraint.rx.constant).disposed(by: dpg)
        InputViewStyleThemes.pwInputHeightType.bind(to: pwHeightConstraint.rx.constant).disposed(by: dpg)
    }
    func bindTextfield() {
        let isAccountValid = accountInputView.textField.rx.text
//        let isAccountValid = accountTextField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false  }
                if ((strongSelf.accountInputView.textField.isFirstResponder) != true) {
                    strongSelf.accountInputView.invalidLabel.isHidden = true
                }
                var patternValue = RegexHelper.Pattern.phone
                if strongSelf.inputMode == .phone || strongSelf.inputMode == .forgotPhone {
                    patternValue = .onlyNumber
                }else
                {
                    patternValue = .mail
                }
                return RegexHelper.match(pattern: patternValue, input: acc)
        }
        let isAccountHeightType = accountInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let acc = str else { return .accountInvalidHidden }
                if ((strongSelf.accountInputView.textField.isFirstResponder) == true) {
                    var patternValue = RegexHelper.Pattern.phone
                    if strongSelf.inputMode == .phone || strongSelf.inputMode == .forgotPhone {
                        patternValue = .onlyNumber
                    }else
                    {
                        patternValue = .mail
                    }
                    let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .accountInvalidHidden : (acc.isEmpty == true ? .accountInvalidShow : .accountInvalidShow)
                    if resultValue == .accountInvalidShow
                    {
                        strongSelf.accountInputView.invalidLabel.isHidden = false
                    }else
                    {
                        strongSelf.accountInputView.invalidLabel.isHidden = true
                    }
                    return resultValue
                }else
                {
                    if strongSelf.accountInputView.invalidLabel.textColor == .red
                    {
                        return .accountInvalidShow
                    }
                    return .accountInvalidHidden
                }
        }
        isAccountHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
        let isPasswordValid = passwordInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false }
                if ((strongSelf.passwordInputView.textField.isFirstResponder) != true) {
                    strongSelf.passwordInputView.invalidLabel.isHidden = true
                }
                var patternValue = RegexHelper.Pattern.phone
                if strongSelf.inputMode == .phone {
                    patternValue = .password
                }else
                {
                    patternValue = .password
                }
                return RegexHelper.match(pattern: patternValue, input: acc)
        }
        let isPasswordHeightType = passwordInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let acc = str else { return .pwInvalidHidden }
                if ((strongSelf.passwordInputView.textField.isFirstResponder) == true) {
                    var patternValue = RegexHelper.Pattern.phone
                    if strongSelf.inputMode == .phone {
                        patternValue = .password
                    }else
                    {
                        patternValue = .password
                    }
                    let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .pwInvalidHidden : (acc.isEmpty == true ? .pwInvalidShow : .pwInvalidShow)
                    if resultValue == .pwInvalidShow
                    {
                        strongSelf.passwordInputView.invalidLabel.isHidden = false
                    }else
                    {
                        strongSelf.passwordInputView.invalidLabel.isHidden = true
                    }
                    return resultValue
                }else
                {
                    if strongSelf.passwordInputView.invalidLabel.textColor == .red
                    {
                        return .pwInvalidShow
                    }
                    return .pwInvalidHidden
                }
        }
        isPasswordHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)

        if currentShowMode == .forgotEmailPW || currentShowMode == .forgotPhonePW
        {
            isAccountValid.bind(to: accountCheckPassed).disposed(by: dpg)
        }else if currentShowMode == .signupEmail ||
                    currentShowMode == .signupPhone
        {
//            isPasswordValid.bind(to: passwordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//            isRegistrationValid.skip(1).bind(to: registrationInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//            isPasswordValid.skip(1).bind(to: passwordInvalidLabel.rx.isHidden).disposed(by: dpg)
            // 0920 註冊取消驗證碼輸入
            if KeychainManager.share.getRegistrationMode() == true
            {
                // 0920 註冊取消驗證碼輸入
                let isRegistrationValid = registrationInputView.textField.rx.text
                    .map { [weak self] (str) -> Bool in
                        guard let _ = self, let acc = str else { return false }
                        return RegexHelper.match(pattern: .otp, input: acc)
                    }
                Observable.combineLatest(isAccountValid, isPasswordValid , isRegistrationValid)
                    .map {
                        return $0.0 && $0.1 && $0.2
                    } //reget match result
                    .bind(to: accountCheckPassed)
                    .disposed(by: dpg)
            }else
            {
                Observable.combineLatest(isAccountValid, isPasswordValid )
                    .map {
                        return $0.0 && $0.1
                    } //reget match result
                    .bind(to: accountCheckPassed)
                    .disposed(by: dpg)
            }
        }else
        {
//            isPasswordValid.skip(1).bind(to: passwordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
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
    func bindTextfieldReturnKey()
    {
        accountInputView.textField.keyboardType = (currentShowMode == .signupPhone || currentShowMode == .loginPhone) ? .numberPad :.emailAddress
        accountInputView.textField.returnKeyType = .next
//        accountInputView.textField.textContentType = .emailAddress
        if currentShowMode == .loginEmail || currentShowMode == .loginPhone
        {
            passwordInputView.textField.returnKeyType = .done
        }else
        {
            // 0920 註冊取消驗證碼輸入
            if KeychainManager.share.getRegistrationMode() == true
            {
                passwordInputView.textField.returnKeyType = .next
                registrationInputView.textField.returnKeyType = .done
            }else
            {
                passwordInputView.textField.returnKeyType = .done
            }
        }
    }
    func bindBorderColor()
    {
        accountInputView.rxChoosePhoneCodeClick().subscribeSuccess { [self](phoneCode) in
            Log.i("PhoneCode:\(phoneCode)")
            chooseAreaPassed.onNext(phoneCode)
        }.disposed(by: dpg)
        accountInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(account:isChoose)
            resetTFMaskView(account:isChoose)
            resetInputView(view: passwordInputView)
//            accountInputView.textField.sendActions(for: .valueChanged)
            if isChoose == false
            {
                passwordInputView.textField.becomeFirstResponder()
            }
        }.disposed(by: dpg)
        passwordInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(password:isChoose)
            resetTFMaskView(password:isChoose)
            resetInputView(view: accountInputView)
            // 0920 註冊取消驗證碼輸入
            if isChoose == false , currentShowMode == .signupEmail || currentShowMode == .signupPhone
            {
                if KeychainManager.share.getRegistrationMode() == true
                {
                    registrationInputView.textField.becomeFirstResponder()
                }
            }
        }.disposed(by: dpg)
        // 0920 註冊取消驗證碼輸入
        if KeychainManager.share.getRegistrationMode() == true
        {
            registrationInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
                resetInvalidText(regis:isChoose)
                resetTFMaskView(regis:isChoose)
                registrationInputView.invalidLabel.isHidden = true
            }.disposed(by: dpg)
        }
    }
    func resetInvalidText(account:Bool = false ,password:Bool = false ,regis:Bool = false )
    {
        if account == true
        {
            accountInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
        if password == true
        {
            passwordInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
        // 0920 註冊取消驗證碼輸入
        if regis == true
        {
            if KeychainManager.share.getRegistrationMode() == true
            {
                registrationInputView.changeInvalidLabelAndMaskBorderColor(with:"")
            }
        }
    }
    // 重置Border外觀
    func resetTFMaskView(account:Bool = false ,password:Bool = false ,regis:Bool = false ,force:Bool = false )
    {
        if accountInputView.invalidLabel.textColor != .red || force == true
        {
            accountInputView.tfMaskView.changeBorderWith(isChoose:account)
        }
        if passwordInputView.invalidLabel.textColor != .red || force == true
        {
            passwordInputView.tfMaskView.changeBorderWith(isChoose:password)
        }
        // 0920 註冊取消驗證碼輸入
        if KeychainManager.share.getRegistrationMode() == true
        {
            if registrationInputView.invalidLabel.textColor != .red || force == true
            {
                registrationInputView.tfMaskView.changeBorderWith(isChoose:regis)
            }
        }
    }
    func resetInputView(view : InputStyleView)
    {
        if view.invalidLabel.textColor != .red
        {
            view.invalidLabel.isHidden = true
        }
    }
    func rxCheckPassed() -> Observable<Bool> {
        return accountCheckPassed.asObserver()
    }
    func rxChooseAreaPassed() -> Observable<String> {
        return chooseAreaPassed.asObserver()
    }
    func cleanTextField() {
        accountInputView.textField.text = ""
        passwordInputView.textField.text = ""
        accountInputView.textField.sendActions(for: .valueChanged)
        passwordInputView.textField.sendActions(for: .valueChanged)
        accountInputView.invalidLabel.isHidden = true
        passwordInputView.invalidLabel.isHidden = true
        // 0920 註冊取消驗證碼輸入
        if KeychainManager.share.getRegistrationMode() == true
        {
            registrationInputView.textField.text = ""
            registrationInputView.textField.sendActions(for: .valueChanged)
            registrationInputView.invalidLabel.isHidden = true
        }
        resetTFMaskView(force:true)
    }
    
    func setup() {
        let accountView = InputStyleView(inputViewMode: currentShowMode.accountInputMode)
        let passwordView = InputStyleView(inputViewMode: .password)
        self.accountInputView = accountView
        self.passwordInputView = passwordView
        // 0920 註冊取消驗證碼輸入
        if KeychainManager.share.getRegistrationMode() == true
        {
            let registrationView = InputStyleView(inputViewMode: .registration)
            self.registrationInputView = registrationView
        }
 
        self.accountInputView.textField.addTarget(self.passwordInputView.textField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        // 0920 註冊取消驗證碼輸入
        if KeychainManager.share.getRegistrationMode() == true
        {
            self.passwordInputView.textField.addTarget(self.registrationInputView.textField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        }
        acHeightConstraint = NSLayoutConstraint(item: accountInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewDefaultHeight))
        pwHeightConstraint = NSLayoutConstraint(item: passwordInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewPasswordHeight))
        addSubview(accountInputView)
        accountInputView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
            make.height.equalTo(acHeightConstraint.constant)
//            make.height.equalTo(Themes.inputViewDefaultHeight)
        }
        accountInputView.addConstraint(acHeightConstraint)
        
        switch currentShowMode {
        case .loginEmail , .loginPhone:
            addSubview(passwordInputView)
            passwordInputView.snp.makeConstraints { (make) in
                make.top.equalTo(accountInputView.snp.bottom).offset(8)
                make.leading.equalToSuperview().offset(25)
                make.trailing.equalToSuperview().offset(-25)
                make.height.equalTo(pwHeightConstraint.constant)
//                make.height.equalTo(Themes.inputViewPasswordHeight)
            }
            passwordInputView.addConstraint(pwHeightConstraint)
        case .signupEmail , .signupPhone:
            addSubview(passwordInputView)
            passwordInputView.snp.makeConstraints { (make) in
                make.top.equalTo(accountInputView.snp.bottom).offset(8)
                make.leading.equalToSuperview().offset(25)
                make.trailing.equalToSuperview().offset(-25)
                make.height.equalTo(pwHeightConstraint.constant)
//                make.height.equalTo(Themes.inputViewPasswordHeight)
            }
            passwordInputView.addConstraint(pwHeightConstraint)
            // 0920 註冊取消驗證碼輸入
            if KeychainManager.share.getRegistrationMode() == true
            {
                addSubview(registrationInputView)
                registrationInputView.snp.makeConstraints { (make) in
                    make.top.equalTo(passwordInputView.snp.bottom).offset(8)
                    make.leading.equalToSuperview().offset(25)
                    make.trailing.equalToSuperview().offset(-25)
                    make.height.equalTo(Themes.inputViewDefaultHeight)
                }
            }
        case .forgotEmailPW ,.forgotPhonePW:
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
            // 0920 註冊取消驗證碼輸入
            if KeychainManager.share.getRegistrationMode() == true
            {
                if registrationInputView.textField.text?.lowercased() == subData.rejectValue.lowercased()
                {
                    registrationInputView.changeInvalidLabelAndMaskBorderColor(with: subData.reason)
                }
            }
        }
    }
    func resignAllResponder()
    {
        resetTFMaskView()
        accountInputView.textField.resignFirstResponder()
        passwordInputView.textField.resignFirstResponder()
        // 0920 註冊取消驗證碼輸入
        if KeychainManager.share.getRegistrationMode() == true
        {
            registrationInputView.textField.resignFirstResponder()
        }
    }
//    func changeInputMode(mode: LoginMode) {
//        inputMode = mode
//        accountInputView.resetUI()
//        passwordInputView.resetUI()
//        registrationInputView.resetUI()
//    }
}
