//
//  VerifyViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.

import UIKit
import Parchment
import RxSwift
import RxCocoa
import Toaster
import AVFoundation
import AVKit
enum VerificationType
{
    case loginVerity
    case signupVerity
    case forgotPWVerity
    case emailAuthenVerity
    case mobileAuthenVerity
}
class VerifyViewController: BaseViewController {
    // MARK:業務設定
    @IBOutlet weak var topIconTopConstant: NSLayoutConstraint!
    private let cancelImg = UIImage(named: "icon-close")!
    private let onClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    var verificationType : VerificationType = .loginVerity
    private var inputMode: LoginMode = .emailPage
    var isAlreadySetBackView = false
    var timer: Timer?
    private var countTime = Themes.verifyCountTime
    private var verifyCodeString = ""
    var loginDto : LoginPostDto?  {
        didSet {
            if let loginDto = self.loginDto
            {
                verificationType = .loginVerity
                switch loginDto.loginMode {
                case .emailPage:
                    self.sentToLabel.text = "We have sent an email to".localized
                    self.verifyResentLabel.text = "Resend Email".localized
                    self.isMobileMode = false
                case .phonePage:
                    self.sentToLabel.text = "We have sent messages to".localized
                    self.verifyResentLabel.text = "Resend".localized
                    self.isMobileMode = true
                }
                self.userAccountLabel.text = loginDto.toAccountString
                
            }
        }
    }
    var forgotPWDto : LoginPostDto?  {
        didSet {
            if let forgotDto = self.forgotPWDto
            {
                verificationType = .forgotPWVerity
                switch forgotDto.loginMode {
                case .emailPage:
                    self.sentToLabel.text = "We have sent an email to".localized
                    self.verifyResentLabel.text = "Resend Email".localized
                    self.isMobileMode = false
                case .phonePage:
                    self.sentToLabel.text = "We have sent messages to".localized
                    self.verifyResentLabel.text = "Resend".localized
                    self.isMobileMode = true
                }
                self.userAccountLabel.text = forgotDto.toAccountString
            }
        }
    }
    var signupDto : SignupPostDto?  {
        didSet {
            if let signupDto = self.signupDto
            {
                verificationType = .signupVerity
                switch signupDto.signupMode {
                case .emailPage:
                    self.sentToLabel.text = "We have sent an email to".localized
                    self.verifyResentLabel.text = "Resend Email".localized
                    self.isMobileMode = false
                case .phonePage:
                    self.sentToLabel.text = "We have sent messages to".localized
                    self.verifyResentLabel.text = "Resend".localized
                    self.isMobileMode = true
                }
                self.userAccountLabel.text = signupDto.toAccountString
            }
        }
    }
    var emailAuthenDto : LoginPostDto?  {
        didSet {
            if let loginDto = self.emailAuthenDto
            {
                verificationType = .emailAuthenVerity
                self.sentToLabel.text = "We have sent an email to".localized
                self.verifyResentLabel.text = "Resend Email".localized
                self.userAccountLabel.text = loginDto.toAccountString
                self.isMobileMode = false
            }
        }
    }
    var mobileAuthenDto : LoginPostDto?  {
        didSet {
            if let loginDto = self.mobileAuthenDto
            {
                verificationType = .mobileAuthenVerity
                self.sentToLabel.text = "We have sent messages to".localized
                self.verifyResentLabel.text = "Resend".localized
                self.userAccountLabel.text = loginDto.toAccountString
                self.isMobileMode = true
            }
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var userAccountLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var topIconImageView: UIImageView!
    lazy var idVerifiVC = IDVerificationViewController.loadNib()
    lazy var resetPWVC = ResetPasswordViewController.loadNib()
    var verifyInputView : InputStyleView!
    var isMobileMode : Bool = false
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    lazy var verifyResentLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = Themes.gray707EAE
        lb.text = "Resend Email".localized
        lb.font = Fonts.PlusJakartaSansBold(14)
        return lb
    }()
    lazy var underLineView : UIView = {
        let view = UIView()
        view.backgroundColor = Themes.gray707EAE
        return view
    }()
//    let verifyCancelRightButton = UIButton()
    lazy var verifyButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    static func instance(loginDto : LoginPostDto? = nil,
                         forgotPWDto : LoginPostDto? = nil,
                         signupDto : SignupPostDto? = nil,
                         emailAuthenDto : LoginPostDto? = nil,
                         mobileAuthenDto : LoginPostDto? = nil) -> VerifyViewController {
        let vc = VerifyViewController.loadNib()
        if let loginData = loginDto
        {
            vc.loginDto = loginData
        }
        if let forgotData = forgotPWDto
        {
            vc.forgotPWDto = forgotData
        }
        if let signupData = signupDto
        {
            vc.signupDto = signupData
        }
        if let emailAuthenData = emailAuthenDto
        {
            vc.emailAuthenDto = emailAuthenData
        }
        if let mobileAuthenData = mobileAuthenDto
        {
            vc.mobileAuthenDto = mobileAuthenData
        }
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verification"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
        setupUI()
        bindPwdButton()
        bindTextfield()
        bindResetPWVC()
        bindBorderColor()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifyResentPressed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isAlreadySetBackView != true
        {
            isAlreadySetBackView = true
            setupBackgroundView()
        }
    }
    func setupBackgroundView()
    {
        backgroundImageView.snp.updateConstraints { (make) in
            make.top.equalTo(topIconImageView).offset(-38)
        }
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
           
            if ((verifyInputView?.textField.isFirstResponder) == true)
            {
                let diffHeight = Views.screenHeight - verifyInputView.frame.maxY
                if diffHeight < (keyboardHeight + 50)
                {
                    let upHeight = (keyboardHeight + 50) - diffHeight
                    topIconTopConstant.constant -= upHeight
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        topIconTopConstant.constant = 50
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        verifyInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        view.backgroundColor = Themes.grayF4F7FE
        let verify = InputStyleView(inputViewMode: .securityVerification)
        verifyInputView = verify
        view.addSubview(verifyInputView)
        view.addSubview(verifyButton)
        view.addSubview(verifyResentLabel)
        view.addSubview(underLineView)

        verifyInputView.snp.makeConstraints { (make) in
            make.top.equalTo(userAccountLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(26)
            make.trailing.equalToSuperview().offset(-26)
            make.centerX.equalTo(userAccountLabel)
            make.height.equalTo(Themes.inputViewDefaultHeight)
        }

        verifyButton.setTitle("Verify".localized, for: .normal)
        verifyButton.snp.makeConstraints { (make) in
            make.top.equalTo(verifyInputView.snp.bottom).offset(20)
            make.centerX.equalTo(userAccountLabel)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        verifyResentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(verifyButton.snp.bottom).offset(20)
            make.centerX.equalTo(userAccountLabel)
//            make.height.equalTo(view).multipliedBy(0.05)
        }
        underLineView.snp.makeConstraints { (make) in
            make.top.equalTo(verifyResentLabel.snp.bottom).offset(1)
            make.width.centerX.equalTo(verifyResentLabel)
            make.height.equalTo(1)
        }
    }
    func resetInvalidText()
    {
        verifyInputView.changeInvalidLabelAndMaskBorderColor(with:"")
    }
    func resetTFMaskView()
    {
        verifyInputView.tfMaskView.changeBorderWith(isChoose:true)
    }
    func bindBorderColor()
    {
        verifyInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText()
            resetTFMaskView()
        }.disposed(by: dpg)
    }
    func bindPwdButton()
    {
        verifyResentLabel.rx.click
            .subscribeSuccess { [weak self] in
                self?.verifyResentPressed()
            }.disposed(by: dpg)

        verifyButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.verifyButtonPressed()
            }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        verifyInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            verifyInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            verifyInputView.changeInvalidLabelAndMaskBorderColor(with:"")
            verifyInputView.invalidLabel.isHidden = true
        }.disposed(by: dpg)
        let isValid = verifyInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. otp, input: acc)
        }
        isValid.skip(1).bind(to: verifyInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isValid.bind(to: verifyButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func bindResetPWVC()
    {
//        resetPWVC.rxSubmitClick().subscribeSuccess { [self] dataString in
//            // 發送驗證碼跟密碼
//            // dataString 新密碼
//            // verifyCodeString 驗證碼
//            // 先讓他去
//            Log.v("新密碼 : \(dataString)\n驗證碼 : \(verifyCodeString)")
//            resetPWVC.gotoFinalVC()
//        }.disposed(by: dpg)
    }
    func verifyButtonPressed()
    {
        var accountString = ""
        var passwordString = ""
        var registrationString = ""
        var mode : LoginMode = .emailPage
        if let loginDto = self.loginDto
        {
            accountString = loginDto.toAccountString
            passwordString = loginDto.password
            mode = loginDto.loginMode
        }else if let signupDto = self.signupDto
        {
            accountString = signupDto.toAccountString
            passwordString = signupDto.password
            registrationString = signupDto.registration
            mode = signupDto.signupMode
        }else if let forgotDto = self.forgotPWDto
        {
            accountString = forgotDto.toAccountString
            mode = forgotDto.loginMode
        }else if let smsAuthenDto = self.mobileAuthenDto
        {
            accountString = smsAuthenDto.toAccountString
            mode = smsAuthenDto.loginMode
        }else if let emailAuthenDto = self.emailAuthenDto
        {
            accountString = emailAuthenDto.toAccountString
            mode = emailAuthenDto.loginMode
        }
        let codeString = verifyInputView.textField.text ?? ""
        verifyButton.isEnabled = false
        switch verificationType {
        case .loginVerity:
            // 登入驗證
            fetchAuthenticationData(with: accountString,
                                    password: passwordString,
                                    verificationCode: codeString)
        case .signupVerity:
            // 註冊驗證
            fetchRegistrationData(code:registrationString,
                                  account:accountString,
                                  password: passwordString,
                                  verificationCode: codeString)
        case .forgotPWVerity:
            fetchForgotPasswordVerify(mode:mode ,
                                      account: accountString,
                                      verificationCode: codeString)
        case .emailAuthenVerity:
            Log.i("要去打 email authentication API")
            fetchEmailAuthenticationData(withEmail: accountString, verificationCode: codeString)
        case .mobileAuthenVerity:
            Log.i("要去打 mobile authentication API")
            fetchSMSAuthenticationData(phone: accountString, verificationCode: codeString)
        }
    }
    func verifyResentLabelVisable(With enable:Bool)
    {
        if enable == true
        {
            verifyResentLabel.text = (isMobileMode ? "Resend".localized : "Resend Email".localized)
            verifyResentLabel.textColor = Themes.gray707EAE
            underLineView.isHidden = false
            verifyResentLabel.isUserInteractionEnabled = true
        }else
        {
            verifyResentLabel.isUserInteractionEnabled = false
            verifyResentLabel.textColor = Themes.grayE0E5F2
        }
    }
    func verifyResentPressed()
    {
        Log.v("重發驗證")
        verifyResentLabelVisable(With: false)
        if self.timer == nil
        {
            var idString = ""
            if let loginDto = self.loginDto
            {
                idString = loginDto.toAccountString
            }else if let signupDto = self.signupDto
            {
                idString = signupDto.toAccountString
            }else if let forgetDto = self.forgotPWDto
            {
                idString = forgetDto.toAccountString
            }else if let emailAuthenDto = self.emailAuthenDto
            {
                idString = emailAuthenDto.toAccountString
            }else if let mobileAuthenDto = self.mobileAuthenDto
            {
                idString = mobileAuthenDto.toAccountString
            }
            Beans.loginServer.verificationResend(idString: idString).subscribe { [self]dto in
                if let dataDto = dto
                {
                    countTime = (dataDto.nextTimestamp - dataDto.currentTimestamp)/1000
                    if countTime <= Themes.verifyCountTime
                    {
                        countTime = Themes.verifyCountTime
                    }
                    defaultSetup()
                }
            } onError: { [self]error in
                if let errorData = error as? ApiServiceError
                {
                    switch errorData {
                    case .noData:
                        defaultSetup()
                    default:
                        ErrorHandler.show(error: error)
                    }
                }
            }.disposed(by: dpg)
        }
    }
    // 登入
    func fetchAuthenticationData(with idString:String ,
                                 password:String ,
                                 verificationCode:String)
    {
        if let loginDto = self.loginDto
        {
            if let vc = self.navigationController?.viewControllers.first , vc is LoginSignupViewController
            {
                let newVC: LoginSignupViewController = vc as! LoginSignupViewController
                newVC.gotoLoginAction(with: idString,
                                   password: password,
                                   verificationCode: verificationCode,
                                   loginDto: loginDto)
            }
//            LoginSignupViewController.share.gotoLoginAction(with: idString,
//                                                            password: password,
//                                                            verificationCode: verificationCode,
//                                                            loginDto: loginDto)
        }
    }
    // 註冊
    func fetchRegistrationData(code:String ,
                               account:String ,
                               password:String ,
                               verificationCode : String)
    {
        if let signupDto = self.signupDto
        {
            LoginSignupViewController.share.gotoSignupAction(code: code,
                                                             account: account,
                                                             password: password,
                                                             verificationCode: verificationCode ,
                                                             signupDto: signupDto)
        }
    }
    // 忘記密碼
    func fetchForgotPasswordVerify(mode:LoginMode ,
                                   account:String ,
                                   verificationCode:String)
    {
        Beans.loginServer.customerForgotPasswordVerify(mode:mode ,accountString: account.localizedLowercase, verificationCode: verificationCode).subscribe { [self] dto in
            if let currentData = dto
            {
                Log.i("成功回傳 \(currentData)")
                let codeString = currentData.code
                directToResetPWVC(codeString)                
            }
        } onError: { [self] error in
            _ = LoadingViewController.dismiss()
            if let error = error as? ApiServiceError
            {
                showAlertByMessage(error: error , withEmail: mode == .emailPage ? true:false)
            }
        }.disposed(by: disposeBag)
    }
    // SMS Authentication
    func fetchSMSAuthenticationData(phone:String ,
                                    verificationCode:String)
    {
        Log.i("執行SMS Authen")
        gotoVerifyCodeWithNewBindAccount(idString: phone, codeString: verificationCode ,withEmail: false)
    }
    // Email Authentication
    func fetchEmailAuthenticationData(withEmail emailString:String ,
                                 verificationCode:String)
    {
        Log.i("執行Email Authen")
        gotoVerifyCodeWithNewBindAccount(idString: emailString, codeString: verificationCode,withEmail: true)
    }
    
    func gotoVerifyCodeWithNewBindAccount(idString: String, codeString: String, withEmail:Bool = false)
    {
        Beans.loginServer.customerSettingsAuthentication(idString: idString, codeString: codeString).subscribe { [self] dataDto in
            Log.i("已將帳號綁定")
            if let lastDto = KeychainManager.share.getLastAccountDto()
            {
                if let email = dataDto?.email as? String
                {
                    MemberAccountDto.share?.email = email
                    KeychainManager.share.saveAccPwd(acc: email,
                                                     pwd: lastDto.password,
                                                     phoneCode: lastDto.phoneCode,
                                                     phone: MemberAccountDto.share?.phone ?? "")
                }
                if let phone = dataDto?.phone?.stringValue
                {
                    MemberAccountDto.share?.phone = phone
                    KeychainManager.share.saveAccPwd(acc: lastDto.account,
                                                     pwd: lastDto.password,
                                                     phoneCode: lastDto.phoneCode,
                                                     phone: phone)
                }
            }
            popToCorrectVC()
        } onError: { [self] error in
            _ = LoadingViewController.dismiss()
            if let error = error as? ApiServiceError
            {
                showAlertByMessage(error: error, withEmail: withEmail)
            }
        }.disposed(by: disposeBag)
    }
    func popToCorrectVC()
    {
        let controllers = self.navigationController?.viewControllers
        for vc in controllers! {
            if vc is SecurityViewController {
                _ = self.navigationController?.popToViewController(vc as! SecurityViewController, animated: true)
            }else if vc is PersonalInfoViewController {
                _ = self.navigationController?.popToViewController(vc as! PersonalInfoViewController, animated: true)
            }
        }
    }
    func showAlertByMessage(error:ApiServiceError , withEmail:Bool = false)
    {
        switch error {
        case .errorDto(let dto):
            let status = dto.httpStatus ?? ""
            let reason = dto.reason
            let emailMessage = "The Email Code is incorrect. Please re-enter."
            let mobileMessage = "The Mobile Code is incorrect. Please re-enter."
            if status == "400"
            {
                if reason == "CODE_MISMATCH"
                {
                    verifyInputView.changeInvalidLabelAndMaskBorderColor(with: withEmail ? emailMessage : mobileMessage)
                }else if reason == "CUSTOMER_EMAIL_OR_PHONE_EXISTS"
                {
                    popToCorrectVC()
                    ErrorHandler.show(error: error)
                }else if reason == "PARAMETER_INVALID"
                {
                    ErrorHandler.show(error: error)
                }else
                {
                    popToCorrectVC()
                    ErrorHandler.show(error: error)
                }
            }else if status == "404"
            {
                verifyInputView.changeInvalidLabelAndMaskBorderColor(with: reason)
            }else
            {
                ErrorHandler.show(error: error)
            }
        default:
            ErrorHandler.show(error: error)
        }
    }
    func directToResetPWVC(_ verifyString : String)
    {
        verifyCodeString = verifyString
        if var data = self.forgotPWDto
        {
            data.resetCode = verifyString
            self.resetPWVC.resetPWDto = data
        }
        self.navigationController?.pushViewController(resetPWVC, animated: true )
    }
    func defaultSetup()
    {
        setupTimer()
        underLineView.isHidden = true
    }
    func setupTimer()
    {
        timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
    @objc func countDown()
    {
        print("count timer: \(countTime)")
        countTime -= 1
        if countTime == 0 {
//            tfRightBtn.setImageTitle(image: nil, title: rightBtnTitle())
//            tfRightBtn.isEnabled = true
            verifyResentLabelVisable(With: true)
            timer?.invalidate()
            timer = nil
            countTime = Themes.verifyCountTime
            return
        }
        verifyResentLabel.text = "Resend in ".localized + "\(countTime) s"
        verifyResentLabelVisable(With: false)
    }
    @objc func popVC(isAnimation : Bool = true)
    {
        _ = self.navigationController?.popViewController(animated: isAnimation)
    }
}
// MARK: -
// MARK: 延伸

