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
    private var mundoCoinRememberMeStatus: Bool = false
    var afterRMAction: Bool = false
    private var timer: Timer?
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    private var onClickLogin = PublishSubject<LoginPostDto>()
    private var onClickForgot = PublishSubject<Void>()
    private var isNetWorkConnectIng = false
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
        tfLabel.font = Fonts.PlusJakartaSansBold(13)
        tfLabel.textColor = Themes.gray707EAE
        tfLabel.numberOfLines = 0
        tfLabel.adjustsFontSizeToFitWidth = true
        tfLabel.minimumScaleFactor = 0.8
        tfLabel.isUserInteractionEnabled = true
        tfLabel.isGrayColor = true
        tfLabel.text = "Forgot Password ?".localized
        return tfLabel
    }()
    @IBOutlet weak private var forgetPasswordButton: UIButton!
    @IBOutlet weak var loginButton: CornerradiusButton!
    @IBOutlet weak var checkBoxView: CheckBoxView!
    @IBOutlet weak var rememberMeLabel: UILabel!
    var accountInputView: AccountInputView!

    // MARK: -
    // MARK:Life cycle
    static func instance(mode: LoginMode) -> LoginViewController {
        let vc = LoginViewController.loadNib()
        vc.loginMode = mode
        vc.secondViewDidLoad()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let acView = accountInputView , afterRMAction == false
        {
            acView.cleanTextField()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detectRememberMeAction()
    }
    func secondViewDidLoad()
    {
        setup()
        bindLoginBtn()
        bindAccountView()
        accountInputView?.bindTextfield()
        addKeyboardAction()
        bindCheckBox()
    }
    func detectRememberMeAction()
    {
        if KeychainManager.share.getMundoCoinRememberMeEnable() == false
        {
            checkBoxView.isSelected = false
            checkBoxView.isHidden = true
            rememberMeLabel.isHidden = true
            KeychainManager.share.saveMundoCoinRememberMeStatus(false)
        }else
        {
            // 取得RM功能狀態
            if KeychainManager.share.getMundoCoinRememberMeStatus() == true
            {
                // 取得上次登入資料
//                if afterRMAction == false,
//                   let loginPostDto = KeychainManager.share.getLastAccountDto(),
//                   (BioVerifyManager.share.usedBIOVeritfy(loginPostDto.account) ||
//                    BioVerifyManager.share.usedBIOVeritfy(loginPostDto.phone))
                if afterRMAction == false,
                   let loginPostDto = KeychainManager.share.getLastAccountDto()
                {
                    DispatchQueue.main.async { [self] in
                        var accountString = ""
                        var phoneCodeString = ""
//                        var passString = ""
                        if loginMode == .phonePage
                        {
                            accountString = loginPostDto.phoneWithoutCode
                            phoneCodeString = loginPostDto.phoneCodeWithoutPhone
//                            passString = ( accountString.isEmpty == true ? "" : loginPostDto.password)
                        }else
                        {
                            accountString = ( loginPostDto.account)
//                            passString = ( accountString.isEmpty ? "" : loginPostDto.password)
                        }

                        accountInputView.accountInputView.textField.text = accountString
                        accountInputView.accountInputView.mobileCodeLabel.text = phoneCodeString
//                        accountInputView.passwordInputView.textField.text = passString
                        checkBoxView.isSelected = true
                        checkBoxView.checkType = .checkType
                        accountInputView.accountInputView.textField.sendActions(for: .valueChanged)
                        accountInputView.passwordInputView.textField.sendActions(for: .valueChanged)
                        // 登入資料寫入完成
                        afterRMAction = true
                    }
                }
                else
                {
                    // 去別頁面閃回或者沒拿到資料
                    //暫時強制寫上
//                    checkBoxView.isSelected = true
//                    checkBoxView.checkType = .checkType
                }
            }
            else
            {
                checkBoxView.isSelected = false
                checkBoxView.checkType = .defaultType
            }
        }
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
    
    // MARK: - UI
    
    func setDefault() {
        stopTimer()
        accountInputView?.passwordInputView.displayRightButton.setTitle("", for: .normal)
    }
    
    func cleanTextField() {
        if afterRMAction == false
        {
            self.accountInputView?.cleanTextField()            
        }
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
        case .emailPage: return "E-mail".localized
        case .phonePage: return "Mobile".localized
        }
    }
    
    func setup() {
        switch loginMode {
        case .emailPage:
            accountInputView = AccountInputView(inputMode: loginMode.inputViewMode,
                                                currentShowMode: .loginEmail,
                                                lineColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        case .phonePage:
            accountInputView = AccountInputView(inputMode: loginMode.inputViewMode,
                                                currentShowMode: .loginPhone,
                                                lineColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        }
        
//        self.rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
        view.addSubview(accountInputView!)
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(Themes.inputViewDefaultHeight + Themes.inputViewPasswordHeight)
        }
        view.addSubview(forgetPasswordLabel)
        view.addSubview(loginButton)
        view.addSubview(checkBoxView)
        view.addSubview(rememberMeLabel)
        
        forgetPasswordLabel.snp.makeConstraints { (make) in
            make.left.equalTo(accountInputView!).offset(32)
            make.top.equalTo(accountInputView!.passwordInputView.snp.bottom).offset(34)
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
        forgetPasswordLabel.isHidden = false
// MC524 暫時隱藏
//    forgetPasswordLabel.isHidden = true
#endif
        forgetPasswordLabel.rx.click.subscribeSuccess { [self] _ in
            onClickForgot.onNext(())
        }.disposed(by: disposeBag)
        loginButton.setTitle("Log In".localized, for: .normal)
        
        checkBoxView.snp.makeConstraints { make in
            make.bottom.equalTo(self.forgetPasswordLabel.snp.top).offset(-12)
            make.left.equalTo(self.forgetPasswordLabel.snp.left)
            make.size.equalTo(20.0)
        }
        rememberMeLabel.snp.makeConstraints { make in
            make.left.equalTo(self.checkBoxView.snp.right).offset(10)
            make.centerY.equalTo(self.checkBoxView)
        }
    }
    
    func showVerifyCode(_ code: String) {
        self.accountInputView?.passwordInputView.textField.text = code
        self.accountInputView?.passwordInputView.textField.sendActions(for: .valueChanged)
    }
    
    //MARK: Actions
    func bindAccountView() {
        accountInputView.rxCheckPassed()
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        accountInputView.rxChooseAreaPassed().subscribeSuccess { [self] phoneCode in
            let searchVC = SelectViewController.loadNib()
            searchVC.currentSelectMode = .selectArea(phoneCode)
            searchVC.rxSelectedAreaCodeClick().subscribeSuccess { [self] selectedCode in
                accountInputView.accountInputView.mobileCodeLabel.text = selectedCode
            }.disposed(by: disposeBag)
            searchVC.modalPresentationStyle = .popover
            self.present(searchVC, animated: true)
        }.disposed(by: disposeBag)
    }

    func bindLoginBtn() {
        loginButton.rx.tap.subscribeSuccess { [self] _ in
            loginButton.isEnabled = false
            accountInputView?.resignAllResponder()
#if Approval_PRO || Approval_DEV || Approval_STAGE
            Log.v("帳號不驗證")
            login()
#else
            if isNetWorkConnectIng != true
            {
                isNetWorkConnectIng = true
                verificationID()
            }
#endif
            }.disposed(by: disposeBag)
    }
    func bindCheckBox()
    {
        checkBoxView.rxCheckBoxPassed().subscribeSuccess { [self] isSelect in
            Log.v("isselect \(isSelect)")
            mundoCoinRememberMeStatus = isSelect
//            KeychainManager.share.saveMundoCoinRememberMeStatus(isSelect)
        }.disposed(by: disposeBag)
    }
    func verificationID()
    {
        guard let account = accountInputView?.accountInputView.textField.text?.lowercased() else {return}
        guard let pwString = accountInputView?.passwordInputView.textField.text else {return}
        let phoneCode = accountInputView?.accountInputView.mobileCodeLabel.text ?? ""
        let accountString = loginMode == .phonePage ? (phoneCode + account) : account
        Beans.loginServer.verificationIDPost(idString: accountString , pwString: pwString).subscribe { [self] dto in
            Log.v("帳號有註冊過")
            login()
        } onError: { [self] error in
            isNetWorkConnectIng = false
            //先測試
//            let account = (loginMode == .phonePage ? account : phone)
//            KeychainManager.share.setLastAccount(account)
//            KeychainManager.share.saveAccPwd(acc: account,
//                                             pwd: pwString,
//                                             phoneCode: phoneCode,
//                                             phone: phone)
//            BioVerifyManager.share.applyMemberInBIOList(account)
            if let error = error as? ApiServiceError {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    var verifyString = "Email"
                    if status == "400"
                    {
                        if reason == "ID_OR_PASSWORD_NOT_MATCH"
                        {
                            verifyString = loginMode == .emailPage ? "Email" : "Mobile"
                            accountInputView?.passwordInputView.changeInvalidLabelAndMaskBorderColor(with: "\(verifyString) or password error")
                            InputViewStyleThemes.share.pwAcceptInputHeightStyle(.pwInvalidShow)
                        }
                    }else if status == "404"
                    {
                        if reason == "Provided Id not exist"
                        {
                            accountInputView?.accountInputView.changeInvalidLabelAndMaskBorderColor(with: "Account is not exist")
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
        let phoneCode = accountInputView?.accountInputView.mobileCodeLabel.text ?? ""
        let phoneString = (self.loginMode == .phonePage ? (phoneCode + account) : "")
        let accountString = account
        let showMode : ShowMode = (self.loginMode == .phonePage ? .loginPhone : .loginEmail )
        let dto = LoginPostDto(account: accountString,
                               password: password,
                               loginMode: self.loginMode ,
                               showMode: showMode ,
                               phoneCode: phoneCode ,
                               phone: phoneString ,
                               rememberMeStatus: mundoCoinRememberMeStatus)
//        // 更改RM 狀態
//        KeychainManager.share.saveMundoCoinRememberMeStatus(mundoCoinRememberMeStatus)
        // 登入成功後
        self.isNetWorkConnectIng = false
        self.onClickLogin.onNext(dto)
    }
    func startReciprocal() {
//        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPwdRightBtnSecondTime), userInfo: nil, repeats: true)
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


