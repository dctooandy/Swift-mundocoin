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
        
        oldInputView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(110)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        newInputView.snp.makeConstraints { (make) in
            make.top.equalTo(oldInputView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        confirmInputView.snp.makeConstraints { (make) in
            make.top.equalTo(newInputView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmInputView.snp.bottom).offset(20)
            make.centerX.equalTo(confirmInputView)
            make.width.equalToSuperview().multipliedBy(0.7)
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
        let isoldValid = oldInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                let resultValue = RegexHelper.match(pattern: .password, input: acc)
                if resultValue != true , (self.oldInputView.textField.isFirstResponder) == true
                {
                    self.oldInputView.invalidLabel.isHidden = false
                }else
                {
                    self.oldInputView.invalidLabel.isHidden = true
                }
                return resultValue
        }
        let isnewValid = newInputView.textField.rx.text
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
                if resultValue != true, (self.newInputView.textField.isFirstResponder) == true
                {
                    self.newInputView.invalidLabel.isHidden = false
                }else
                {
                    self.newInputView.invalidLabel.isHidden = true
                }
                return resultValue
        }
        let isconfirmValid = confirmInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                let resultValue = (acc == self.newInputView.textField.text) &&
                    RegexHelper.match(pattern: .password, input: acc)
                if resultValue != true, (self.confirmInputView.textField.isFirstResponder) == true
                {
                    self.confirmInputView.invalidLabel.isHidden = false
                }else
                {
                    self.confirmInputView.invalidLabel.isHidden = true
                }
                return resultValue
        }
        
        isoldValid.skip(1).bind(to: oldInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isnewValid.skip(1).bind(to: newInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isconfirmValid.skip(1).bind(to: confirmInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        Observable.combineLatest(isoldValid, isnewValid,isconfirmValid)
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
    func customerUpdatePassword(Withcode:String)
    {
        if let currentString = oldInputView.textField.text,
        let newString = newInputView.textField.text
        {
            Beans.loginServer.customerUpdatePassword(current: currentString, updated: newString, verificationCode: Withcode).subscribeSuccess { [self]data in
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
                self.navigationController?.pushViewController(changedPWVC, animated: true)
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
    }
    func bindBorderColor()
    {
        oldInputView.rxChooseClick().subscribeSuccess { (isChoose) in
            DispatchQueue.main.async { [self] in
                resetInvalidText()
                resetTFMaskView(old: isChoose)
                newInputView.invalidLabel.isHidden = true
                confirmInputView.invalidLabel.isHidden = true
                if isChoose == false
                {
                    newInputView.textField.becomeFirstResponder()
                }
            }
        }.disposed(by: dpg)
        newInputView.rxChooseClick().subscribeSuccess { (isChoose) in
            DispatchQueue.main.async { [self] in
                resetInvalidText()
                resetTFMaskView(new: isChoose)
                oldInputView.invalidLabel.isHidden = true
                confirmInputView.invalidLabel.isHidden = true
                if isChoose == false
                {
                    confirmInputView.textField.becomeFirstResponder()
                }
            }
        }.disposed(by: dpg)
        confirmInputView.rxChooseClick().subscribeSuccess { (isChoose) in
            DispatchQueue.main.async { [self] in
                resetInvalidText()
                resetTFMaskView(confirm: isChoose)
                oldInputView.invalidLabel.isHidden = true
                newInputView.invalidLabel.isHidden = true
            }
        }.disposed(by: dpg)
    }
    func resetInputView(view : InputStyleView)
    {
        view.invalidLabel.isHidden = true
    }
    func resetTFMaskView(old:Bool = false ,new:Bool = false ,confirm:Bool = false )
    {
        oldInputView.tfMaskView.changeBorderWith(isChoose:old)
        newInputView.tfMaskView.changeBorderWith(isChoose:new)
        confirmInputView.tfMaskView.changeBorderWith(isChoose:confirm)
    }
    func resetInvalidText()
    {
        oldInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        newInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        confirmInputView.changeInvalidLabelAndMaskBorderColor(with:"")
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
                                oldInputView.changeInvalidLabelAndMaskBorderColor(with: reason)
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
