//
//  UCPasswordViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/23.
//


import Foundation
import RxCocoa
import RxSwift

class UCPasswordViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var oldHeightConstraint : NSLayoutConstraint!
    var newHeightConstraint : NSLayoutConstraint!
    var confirmHeightConstraint : NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    let twoFAVC = SecurityVerificationViewController.loadNib()
    fileprivate let changedPWVC = CPasswordViewController.loadNib()
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    var oldInputView : InputStyleView!
    var newInputView : InputStyleView!
    var confirmInputView : InputStyleView!
    let submitButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        setupUI()
        bindTextfield()
        bindTextfieldReturnKey()
        bindCancelButton()
        bindPwdButton()
        bindAction()
        bindBorderColor()
        bindStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearTextField()
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: -
    // MARK:業務方法
    func bindStyle()
    {
        InputViewStyleThemes.oldInputHeightType.bind(to: oldHeightConstraint.rx.constant).disposed(by: dpg)
        InputViewStyleThemes.newInputHeightType.bind(to: newHeightConstraint.rx.constant).disposed(by: dpg)
        InputViewStyleThemes.confirmInputHeightType.bind(to: confirmHeightConstraint.rx.constant).disposed(by: dpg)
    }
    func clearTextField()
    {
        oldInputView.textField.text = ""
        newInputView.textField.text = ""
        confirmInputView.textField.text = ""
        oldInputView.changeInvalidLabelAndMaskBorderColor(with:"")
    }
    func setupUI()
    {
        title = "Change password".localized
        view.backgroundColor = Themes.grayF4F7FE
        let oldView = InputStyleView(inputViewMode: .oldPassword)
        let newView = InputStyleView(inputViewMode: .newPassword)
        let confirmView = InputStyleView(inputViewMode: .confirmPassword)
        oldInputView = oldView
        newInputView = newView
        confirmInputView = confirmView
        view.addSubview(oldInputView)
        view.addSubview(newInputView)
        view.addSubview(confirmInputView)
        view.addSubview(submitButton)
        
        oldHeightConstraint = NSLayoutConstraint(item: oldInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewPasswordHeight))
        newHeightConstraint = NSLayoutConstraint(item: newInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewPasswordHeight))
        confirmHeightConstraint = NSLayoutConstraint(item: confirmInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewPasswordHeight))
        
        oldInputView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(115)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(Themes.inputViewPasswordHeight)
            make.height.equalTo(oldHeightConstraint.constant)
        }
        oldInputView.addConstraint(oldHeightConstraint)
        newInputView.snp.makeConstraints { (make) in
            make.top.equalTo(oldInputView.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(Themes.inputViewPasswordHeight)
            make.height.equalTo(newHeightConstraint.constant)
        }
        newInputView.addConstraint(newHeightConstraint)
        confirmInputView.snp.makeConstraints { (make) in
            make.top.equalTo(newInputView.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(Themes.inputViewPasswordHeight)
            make.height.equalTo(confirmHeightConstraint.constant)
        }
        confirmInputView.addConstraint(confirmHeightConstraint)
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmInputView.snp.bottom).offset(27)
            make.centerX.equalTo(confirmInputView)
            make.width.equalToSuperview().multipliedBy(311.0/415.0)
            make.height.equalTo(50)
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        oldInputView.tfMaskView.changeBorderWith(isChoose:false)
        newInputView.tfMaskView.changeBorderWith(isChoose:false)
        confirmInputView.tfMaskView.changeBorderWith(isChoose:false)
        oldInputView.textField.sendActions(for: .valueChanged)
        newInputView.textField.sendActions(for: .valueChanged)
        confirmInputView.textField.sendActions(for: .valueChanged)
    }
    // MARK: -
    // MARK:業務方法
    func bindTextfield()
    {
        let isOldValid = oldInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                let resultValue = RegexHelper.match(pattern: .password, input: acc)
                if (self.oldInputView.textField.isFirstResponder) != true
                {
                    self.oldInputView.invalidLabel.isHidden = true
                }
                return resultValue
        }
        let isOldHeightType = oldInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let acc = str else { return .oldPWInvalidHidden }
                if ((strongSelf.oldInputView.textField.isFirstResponder) == true) {
                    let patternValue = RegexHelper.Pattern.password

                    let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .oldPWInvalidHidden : (acc.isEmpty == true ? .oldPWInvalidShow : .oldPWInvalidShow)
                    if resultValue == .oldPWInvalidShow
                    {
                        strongSelf.oldInputView.invalidLabel.isHidden = false
                    }else
                    {
                        strongSelf.oldInputView.invalidLabel.isHidden = true
                    }
                    return resultValue
                }else
                {
                    if strongSelf.oldInputView.invalidLabel.textColor == .red
                    {
                        return .oldPWInvalidShow
                    }
                    return .oldPWInvalidHidden
                }
        }
        isOldHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
        let isNewValid = newInputView.textField.rx.text
            .map { [self]  (str) -> Bool in
                guard  let acc = str else { return false  }
                var resultValue = false
                if confirmInputView.textField.text == ""
                {
                    resultValue = RegexHelper.match(pattern: .password, input: acc)
                }else
                {
                    resultValue = (acc == confirmInputView.textField.text) &&
                        RegexHelper.match(pattern: .password, input: acc)
                }
                if (self.newInputView.textField.isFirstResponder) != true
                {
                    self.newInputView.invalidLabel.isHidden = true
                }
                return resultValue
        }
        let isNewHeightType = newInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let acc = str else { return .newPWInvalidHidden }
                if ((strongSelf.newInputView.textField.isFirstResponder) == true) {
                    let patternValue = RegexHelper.Pattern.password
                    let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .newPWInvalidHidden : (acc.isEmpty == true ? .newPWInvalidShow : .newPWInvalidShow)
                    if resultValue == .newPWInvalidShow
                    {
                        strongSelf.newInputView.invalidLabel.isHidden = false
                    }else
                    {
                        strongSelf.newInputView.invalidLabel.isHidden = true
                    }
                    return resultValue
                }else
                {
                    if strongSelf.newInputView.invalidLabel.textColor == .red
                    {
                        return .newPWInvalidShow
                    }
                    return .newPWInvalidHidden
                }
        }
        isNewHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
        let isConfirmValid = confirmInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                let resultValue = (acc == self.newInputView.textField.text) &&
                    RegexHelper.match(pattern: .password, input: acc)
                if (self.confirmInputView.textField.isFirstResponder) != true
                {
                    self.confirmInputView.invalidLabel.isHidden = true
                }
                return resultValue
        }
        let isConfirmHeightType = confirmInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let acc = str else { return .confirmPWInvalidHidden }
                if ((strongSelf.confirmInputView.textField.isFirstResponder) == true) {
                    let patternValue = RegexHelper.Pattern.password

                    let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .confirmPWInvalidHidden : (acc.isEmpty == true ? .confirmPWInvalidShow : .confirmPWInvalidShow)
                    if resultValue == .confirmPWInvalidShow
                    {
                        strongSelf.confirmInputView.invalidLabel.isHidden = false
                    }else
                    {
                        strongSelf.confirmInputView.invalidLabel.isHidden = true
                    }
                    return resultValue
                }else
                {
                    if strongSelf.confirmInputView.invalidLabel.textColor == .red
                    {
                        return .confirmPWInvalidShow
                    }
                    return .confirmPWInvalidHidden
                }
        }
        isConfirmHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
//        isOldValid.skip(1).bind(to: oldInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//        isNewValid.skip(1).bind(to: newInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//        isConfirmValid.skip(1).bind(to: confirmInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        Observable.combineLatest(isOldValid, isNewValid,isConfirmValid)
            .map { return $0.0 && $0.1 && $0.2 } //reget match result
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func bindTextfieldReturnKey()
    {
        oldInputView.textField.returnKeyType = .next
        newInputView.textField.returnKeyType = .next
        confirmInputView.textField.returnKeyType = .done
    }
    func bindCancelButton()
    {
//        let _ =  oldInputView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: oldInputView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
//        let _ =  newInputView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: newInputView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
//        let _ =  confirmInputView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: confirmInputView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
    }
    func bindPwdButton()
    {
        submitButton.rx.tap
            .subscribeSuccess { [self] in
                submitButtonPressed()
            }.disposed(by: dpg)
    }
    func customerUpdatePassword(Withcode:String , withMode:String = "")
    {
        if let currentString = oldInputView.textField.text,
        let newString = newInputView.textField.text
        {
            Beans.loginServer.customerUpdatePassword(current: currentString, updated: newString, verificationCode: Withcode).subscribe { [self] data in
                Log.v("更改成功")
                if let currentAcc = KeychainManager.share.getLastAccount()
                {
                    MemberAccountDto.share = MemberAccountDto(account: currentAcc.account,
                                                              password: newString,
                                                              loginMode: currentAcc.loginMode)
                    KeychainManager.share.setLastAccount(currentAcc.account)
                    KeychainManager.share.updateAccount(acc: currentAcc.account,
                                                        pwd: newString)
                    BioVerifyManager.share.applyMemberInBIOList(currentAcc.account)
                }
                changedPWVC.backgroundImageViewHidden()
                changedPWVC.title = "Security Verification"
                self.navigationController?.pushViewController(changedPWVC, animated: true)
            } onError: { [self] error in
                if let error = error as? ApiServiceError {
                    switch error {
                    case .errorDto(let dto):
                        let status = dto.httpStatus ?? ""
                        let reason = dto.reason
                        if status == "400"
                        {
                            if reason == "CODE_MISMATCH"
                            {
                                Log.i("驗證碼錯誤 :\(reason)")
                                if twoFAVC.securityViewMode == .onlyEmail
                                {
                                    twoFAVC.twoFAVerifyView.emailInputView.invalidLabel.isHidden = false
                                    twoFAVC.twoFAVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                }else if twoFAVC.securityViewMode == .onlyTwoFA
                                {
                                    twoFAVC.twoFAVerifyView.twoFAInputView.invalidLabel.isHidden = false
                                    twoFAVC.twoFAVerifyView.twoFAInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                }else if twoFAVC.securityViewMode == .selectedMode
                                {
                                    if withMode == "onlyEmail" , let emailVC = twoFAVC.twoFAViewControllers.first
                                    {
                                        emailVC.verifyView.emailInputView.invalidLabel.isHidden = false
                                        emailVC.verifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                    }else if withMode == "onlyTwoFA" , let twoFAVC = twoFAVC.twoFAViewControllers.last
                                    {
                                        twoFAVC.verifyView.twoFAInputView.invalidLabel.isHidden = false
                                        twoFAVC.verifyView.twoFAInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                    }
                                }else if twoFAVC.securityViewMode == .defaultMode
                                {
                                    if twoFAVC.twoFAVerifyView.twoFAViewMode == .both
                                    {
                                        ErrorHandler.show(error: error)
                                    }
                                }
                            }
                          
                        }else
                        {
                            ErrorHandler.show(error: error)
                        }
                    default:
                        ErrorHandler.show(error: error)
                    }
                }
            }.disposed(by: dpg)
        }
    }
    func bindAction()
    {
        // MC524 暫時隱藏
//        twoFAVC.securityViewMode = .selectedMode
        twoFAVC.securityViewMode = .onlyEmail
        twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self](stringData) in
            customerUpdatePassword(Withcode: stringData.0)
        }.disposed(by: dpg)
        twoFAVC.rxSelectedModeSuccessClick().subscribeSuccess { [self](stringData) in
            customerUpdatePassword(Withcode: stringData.0,withMode: stringData.1)
        }.disposed(by: dpg)
    }
    func bindBorderColor()
    {
        oldInputView.rxChooseClick().subscribeSuccess { (isChoose) in
            DispatchQueue.main.async { [self] in
                resetInvalidText(oldPW:isChoose)
                resetTFMaskView(old: isChoose)
                resetInputView(view: newInputView)
//                newInputView.invalidLabel.isHidden = true
//                confirmInputView.invalidLabel.isHidden = true
                if isChoose == false
                {
                    newInputView.textField.becomeFirstResponder()
                }
            }
        }.disposed(by: dpg)
        newInputView.rxChooseClick().subscribeSuccess { (isChoose) in
            DispatchQueue.main.async { [self] in
                resetInvalidText(newPW:isChoose)
                resetTFMaskView(new: isChoose)
                resetInputView(view: confirmInputView)
//                oldInputView.invalidLabel.isHidden = true
//                confirmInputView.invalidLabel.isHidden = true
                if isChoose == false
                {
                    confirmInputView.textField.becomeFirstResponder()
                }
            }
        }.disposed(by: dpg)
        confirmInputView.rxChooseClick().subscribeSuccess { (isChoose) in
            DispatchQueue.main.async { [self] in
                resetInvalidText(confirmPW:isChoose)
                resetTFMaskView(confirm: isChoose)
                resetInputView(view: newInputView)
//                confirmInputView.invalidLabel.isHidden = true
//                oldInputView.invalidLabel.isHidden = true
//                newInputView.invalidLabel.isHidden = true
            }
        }.disposed(by: dpg)
    }

    func resetTFMaskView(old:Bool = false ,new:Bool = false ,confirm:Bool = false ,force:Bool = false)
    {
        if oldInputView.invalidLabel.textColor != .red || force == true
        {
            oldInputView.tfMaskView.changeBorderWith(isChoose:old)
        }
        if newInputView.invalidLabel.textColor != .red || force == true
        {
            newInputView.tfMaskView.changeBorderWith(isChoose:new)
        }
        if confirmInputView.invalidLabel.textColor != .red || force == true
        {
            confirmInputView.tfMaskView.changeBorderWith(isChoose:confirm)
        }
    }
    func resetInputView(view : InputStyleView)
    {
        if view.invalidLabel.textColor != .red
        {
            view.invalidLabel.isHidden = true
        }
    }
    func resetInvalidText(oldPW:Bool = false ,newPW:Bool = false ,confirmPW:Bool = false )
    {
        if oldPW == true
        {
            oldInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
        if newPW == true
        {
            newInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
        if confirmPW == true
        {
            confirmInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
    }
    func submitButtonPressed()
    {
        verificationID()
    }
    func verificationID()
    {
        guard let account = KeychainManager.share.getLastAccount()?.account else {return}
        guard let pwString = oldInputView.textField.text else {return}
        LoadingViewController.show()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
            Beans.loginServer.verificationIDPost(idString: account , pwString: pwString).subscribe { [self] dto in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss()
                    Log.v("帳號有註冊過")
                    gotoTwoFAVC()
                }
            } onError: { [self] error in
                if let error = error as? ApiServiceError {
                    _ = LoadingViewController.dismiss().subscribeSuccess { [self] _ in
                        switch error {
                        case .errorDto(let dto):
                            let status = dto.httpStatus ?? ""
                            let reason = dto.reason
                            
                            if status == "400"
                            {
                                if reason == "ID_OR_PASSWORD_NOT_MATCH"
                                {
                                    oldInputView.changeInvalidLabelAndMaskBorderColor(with: "Password incorrect")
                                    InputViewStyleThemes.share.oldAcceptInputHeightStyle(.oldPWInvalidShow)
                                }
                            }else
                            {
                                ErrorHandler.show(error: error)
                            }
                        default:
                            ErrorHandler.show(error: error)
                        }                        
                    }.disposed(by: disposeBag)
                }
            }.disposed(by: disposeBag)
        }
    }
    func gotoTwoFAVC()
    {
        self.navigationController?.pushViewController(twoFAVC, animated: true)
    }

}
// MARK: -
// MARK: 延伸
