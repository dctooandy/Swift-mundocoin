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
enum VerifificationType
{
    case loginVerity
    case signupVerity
    case forgotPWVerity
}
class VerifyViewController: BaseViewController {
    // MARK:業務設定
    @IBOutlet weak var topIconTopConstant: NSLayoutConstraint!
    private let cancelImg = UIImage(named: "icon-close")!
    private let onClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    var verifificationType : VerifificationType = .loginVerity
    private var inputMode: LoginMode = .emailPage
    var isAlreadySetBackView = false
    var timer: Timer?
    private var countTime = 60
    private var verifyCodeString = ""
    var loginDto : LoginPostDto?  {
        didSet {
            if let loginDto = self.loginDto
            {
                verifificationType = .loginVerity
                switch loginDto.loginMode {
                case .emailPage:
                    self.sentToLabel.text = "We have sent an email to".localized
                case .phonePage:
                    self.sentToLabel.text = "We have sent messages to".localized
                }
                self.userAccountLabel.text = loginDto.account
            }
        }
    }
    var forgotPWDto : LoginPostDto?  {
        didSet {
            if let forgotDto = self.forgotPWDto
            {
                verifificationType = .forgotPWVerity
                switch forgotDto.loginMode {
                case .emailPage:
                    self.sentToLabel.text = "We have sent an email to".localized
                case .phonePage:
                    self.sentToLabel.text = "We have sent messages to".localized
                }
                self.userAccountLabel.text = forgotDto.account
            }
        }
    }
    var signupDto : SignupPostDto?  {
        didSet {
            if let signupDto = self.signupDto
            {
                verifificationType = .signupVerity
                switch signupDto.signupMode {
                case .emailPage:
                    self.sentToLabel.text = "We have sent an email to".localized
                case .phonePage:
                    self.sentToLabel.text = "We have sent messages to".localized
                }
                self.userAccountLabel.text = signupDto.account
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
    override func viewDidLoad() {
        super.viewDidLoad()
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
        var idString = ""
        var passwordString = ""
        var registrationString = ""
        if let loginDto = self.loginDto
        {
            idString = loginDto.account
            passwordString = loginDto.password
        }else if let signupDto = self.signupDto
        {
            idString = signupDto.account
            passwordString = signupDto.password
            registrationString = signupDto.registration
        }else if let forgotDto = self.forgotPWDto
        {
            idString = forgotDto.account
        }
        let codeString = verifyInputView.textField.text ?? ""
        switch verifificationType {
        case .loginVerity:
            // 登入驗證
            fetchAuthenticationData(with: idString,
                                    password: passwordString,
                                    verificationCode: codeString)
        case .signupVerity:
            // 註冊驗證
            fetchRegistrationData(code:registrationString,
                                  email: idString,
                                  password: passwordString,
                                  verificationCode: codeString)
        case .forgotPWVerity:
            fetchForgotPasswordVerify(with: idString,
                                      verificationCode: codeString)
        }
    }
    func verifyResentLabelVisable(With enable:Bool)
    {
        if enable == true
        {
            verifyResentLabel.text = "Resend Email".localized
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
                idString = loginDto.account
            }else if let signupDto = self.signupDto
            {
                idString = signupDto.account
            }else if let forgetDto = self.forgotPWDto
            {
                idString = forgetDto.account
            }
            Beans.loginServer.verificationResend(idString: idString).subscribe { [self]dto in
                if let dataDto = dto
                {
                    countTime = (dataDto.nextTimestamp - dataDto.currentTimestamp)/1000
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
            LoginSignupViewController.share.gotoLoginAction(with: idString,
                                                            password: password,
                                                            verificationCode: verificationCode,
                                                            loginDto: loginDto)
        }
    }
    // 註冊
    func fetchRegistrationData(code:String ,
                          email:String = "" ,
                          password:String ,
                          phone:String = "",
                          verificationCode : String)
    {
        if let signupDto = self.signupDto
        {
            LoginSignupViewController.share.gotoSignupAction(code: code,
                                                             email: email,
                                                             password: password,
                                                             phone: phone,
                                                             verificationCode: verificationCode ,
                                                             signupDto: signupDto)
        }
    }
    // 忘記密碼
    func fetchForgotPasswordVerify(with idString:String ,
                                   verificationCode:String)
    {
        Beans.loginServer.customerForgotPasswordVerify(accountString: idString.localizedLowercase, verificationCode: verificationCode).subscribe { [self] dto in
            Log.i("成功回傳 \(dto)")
            if let codeString = dto?.code
            {
                directToResetPWVC(codeString)                
            }
        } onError: { [self] error in
            _ = LoadingViewController.dismiss()
            if let error = error as? ApiServiceError
            {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    if status == "400"
                    {
                        if reason == "CODE_MISMATCH"
                        {
                            verifyInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
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
        }.disposed(by: disposeBag)
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
            countTime = 60
            return
        }
        verifyResentLabel.text = "Resend in ".localized + "\(countTime) s"
        verifyResentLabelVisable(With: false)
    }
    @objc func popVC(isAnimation : Bool = true)
    {
        _ = self.navigationController?.popToRootViewController(animated: isAnimation)
    }
}
// MARK: -
// MARK: 延伸

