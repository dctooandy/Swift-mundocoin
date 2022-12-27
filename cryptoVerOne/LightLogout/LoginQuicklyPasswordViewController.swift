//
//  LoginQuicklyPasswordViewController.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/12/27.
//


import Foundation
import RxCocoa
import RxSwift
typealias PasswordLoginErrorBlock = (ApiServiceError) -> Void
class LoginQuicklyPasswordViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private var withoutFaceIDPrefixVC: Bool = false
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var dismissImageView: UIImageView!
    @IBOutlet weak var loginButton: CornerradiusButton!
    @IBOutlet weak var passwordInputView: InputStyleView!
    // MARK: -
    // MARK:Life cycle
    static func instance(faceIDPrefixVC: Bool) -> LoginQuicklyPasswordViewController {
        let vc = LoginQuicklyPasswordViewController.loadNib()
        vc.withoutFaceIDPrefixVC = faceIDPrefixVC
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        bindImageView()
        setupUI()
        bindTextfield()
        bindBorderColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupBackgroundView()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        passwordInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func setupData()
    {
        if let lastAccount = KeychainManager.share.getLastAccount()
        {
            if lastAccount.components(separatedBy: "@").count > 1
            {
                accountLabel.text = lastAccount.hideEmailAccount()
            }else
            {
                accountLabel.text = lastAccount.hidePhoneAccount()
            }
        }
    }
    func setupBackgroundView()
    {
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
    func setupUI()
    {
        passwordInputView.setMode(mode: .password)
    }
    func bindImageView()
    {
        dismissImageView.rx.click.subscribeSuccess { [self] _ in
            Log.i("去登入")
            if withoutFaceIDPrefixVC == false
            {
                quicklyGoToLogin()
            }else
            {
                self.dismiss(animated: true)
            }
        }.disposed(by: dpg)
        loginButton.rx.tap.subscribeSuccess { [self] _ in
            Log.i("去密碼登入")
            goToPasswordLogin()
        }.disposed(by: dpg)
    }
    func bindTextfield() {
        let isPasswordValid = passwordInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false }
                if ((strongSelf.passwordInputView.textField.isFirstResponder) != true) {
                    strongSelf.passwordInputView.invalidLabel.isHidden = true
                }
                var patternValue = RegexHelper.Pattern.phone
                patternValue = .password
                return RegexHelper.match(pattern: patternValue, input: acc)
        }
        let isPasswordHeightType = passwordInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let acc = str else { return .pwInvalidHidden }
                if ((strongSelf.passwordInputView.textField.isFirstResponder) == true) {
                    var patternValue = RegexHelper.Pattern.phone
                    patternValue = .password
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
        isPasswordValid.bind(to: loginButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func bindBorderColor()
    {
        passwordInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
//            resetInvalidText(password:isChoose)
            passwordInputView.changeInvalidLabelAndMaskBorderColor(with:"")
//            resetTFMaskView(password:isChoose)
            passwordInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            resetInputView(view: passwordInputView)
        }.disposed(by: dpg)
    }
}
// MARK: -
// MARK: 延伸
extension LoginQuicklyPasswordViewController {
    func quicklyGoToLogin()
    {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
        {
            let loginVC = LoginSignupViewController.share
            let loginNavVC = MuLoginNavigationController(rootViewController:loginVC )
            mainWindow.rootViewController = loginNavVC
            mainWindow.makeKeyAndVisible()
        }
    }
    func resetInputView(view : InputStyleView)
    {
        if view.invalidLabel.textColor != .red
        {
            view.invalidLabel.isHidden = true
        }
    }
    func goToPasswordLogin()
    {
        if let loginPostDto = KeychainManager.share.getLastAccountDto(),
           let passwordString = passwordInputView.textField.text
        {
            let idString = loginPostDto.toAccountString
            LoginSignupViewController.share.gotoLoginAction(with: idString, password: passwordString,loginDto: loginPostDto ,withQuicklyLoginPassword: true) { [self] errorData in
                if let error = errorData as? ApiServiceError
                {
                    switch error {
                    case .errorDto(let dto):
                        let reason = dto.reason
                        var verifyString = "Email"
                        if (reason == "CODE_MISMATCH" || reason == "CODE_NOT_FOUND" || reason == "BAD_CREDENTIAL" )
                        {
                            verifyString = loginPostDto.loginMode == .emailPage ? "Email" : "Mobile"
                            passwordInputView.changeInvalidLabelAndMaskBorderColor(with: "The \(verifyString) Code is incorrect. Please re-enter.")
                        }else
                        {
                            let results = ErrorDefaultDto(code: dto.code, reason: reason, timestamp: 0, httpStatus: "", errors: [])
                            ErrorHandler.show(error: ApiServiceError.errorDto(results))
                        }
                    case .noData:
                        dismiss(animated: true)
                    default:
                        ErrorHandler.show(error: error)
                    }
                }
            }
            
        }
    }
}
