//
//  ForgotViewController.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ForgotViewController: BaseViewController {
    // MARK:業務設定
    private var timer: Timer?
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    private var onClickLogin = PublishSubject<LoginPostDto>()
//    var rxVerifyCodeButtonClick: Observable<String>?
    private var loginMode : LoginMode = .emailPage {
        didSet {
//            self.loginModeDidChange()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var sendResetLinkButton: CornerradiusButton!
    @IBOutlet weak var topLabel: UILabel!
    private var accountInputView: AccountInputView?
    // MARK: -
    // MARK:Life cycle
    static func instance(mode: LoginMode) -> ForgotViewController {
        let vc = ForgotViewController.loadNib()
        vc.loginMode = mode
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindLinkBtn()
        bindAccountView()
        setupBackgroundView()
        accountInputView?.bindTextfield()
    }

    // MARK: -
    // MARK:業務方法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        resetInputView()
    }
    
    func setDefault() {
//        stopTimer()
        accountInputView?.passwordInputView.displayRightButton.setTitle("", for: .normal)
    }
    
    func cleanTextField() {
        self.accountInputView?.cleanTextField()
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
        case .emailPage: return "".localized
        case .phonePage: return "Mobile".localized
        }
    }
    
    func setup() {
        view.backgroundColor = Themes.grayF4F7FE
        topLabel.text = "Forgot password".localized
        accountInputView = AccountInputView(inputMode: loginMode.inputViewMode, currentShowMode: .forgotPW, lineColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
//        self.rxVerifyCodeButtonClick = accountInputView?.rxVerifyCodeButtonClick()
        view.addSubview(accountInputView!)
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(Themes.inputViewDefaultHeight)
        }
        view.addSubview(sendResetLinkButton)
        
        sendResetLinkButton.snp.makeConstraints { (make) in
            make.top.equalTo(accountInputView!.snp.bottom).offset(65)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        // set default login mode
        loginModeDidChange()
        sendResetLinkButton.setTitle("Send".localized, for: .normal)
        
    }
    func setupBackgroundView()
    {
//        backgroundImageView.snp.updateConstraints { (make) in
//            make.top.equalTo(topIconImageView).offset(-38)
//        }
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
    func showVerifyCode(_ code: String) {
        self.accountInputView?.passwordInputView.textField.text = code
        self.accountInputView?.passwordInputView.textField.sendActions(for: .valueChanged)
    }
    
    //MARK: Actions
    func bindAccountView() {
        accountInputView!.rxCheckPassed()
            .bind(to: sendResetLinkButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func bindLinkBtn() {
        sendResetLinkButton.rx.tap.subscribeSuccess { [weak self] _ in
                self?.sendReset()
            }.disposed(by: disposeBag)
    }
    
    private func sendReset()
    {
        resetInputView()
        clickLoginActions()
    }
    func resetInputView()
    {
        accountInputView?.resetTFMaskView()
    }
    func clickLoginActions()
    {
        if let account = accountInputView?.accountInputView.textField.text
        {
            let dto = LoginPostDto(account: account, password:"",loginMode: self.loginMode ,showMode: .forgotPW)
            view.endEditing(true)
            showVerifyVCWithLoginData(dto)
//            self.onClickLogin.onNext(dto)y
        }
    }
//    func startReciprocal() {
//        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPwdRightBtnSecondTime), userInfo: nil, repeats: true)
//        self.accountInputView?.setPasswordRightBtnEnable(isEnable: false)
//    }
    
//    @objc private func setPwdRightBtnSecondTime() {
//
//        self.accountInputView?.setPasswordRightBtnTime(seconds)
//        if seconds == 0 {
//            stopTimer()
//            return
//        }
//        seconds -= 1
//    }
    
//    private func stopTimer() {
//        self.timer?.invalidate()
//        self.timer = nil
//        seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
//        self.accountInputView?.setPasswordRightBtnEnable(isEnable: true)
//    }
    func showVerifyVCWithLoginData(_ dataDto: LoginPostDto)
    {
        Beans.loginServer.verificationIDGet(idString: dataDto.account).subscribe { [self] dto in
            Log.v("帳號沒註冊過")
            accountInputView?.accountInputView.changeInvalidLabelAndMaskBorderColor(with: "Account is not exist")
//            willShowAgainFromVerifyVC = true
            // 暫時改為直接推頁面
//            let verifyVC = VerifyViewController.loadNib()
//            verifyVC.loginDto = dataDto
//            navigationController?.pushViewController(verifyVC, animated: true)
        } onError: { [self] error in
            if let error = error as? ApiServiceError {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
//                    let reason = dto.reason
                    if status == "400"
                    {
                        Log.v("帳號已存在")
//                        accountInputView?.accountInputView.changeInvalidLabelAndMaskBorderColor(with: reason)
                        let verifyVC = VerifyViewController.loadNib()
                        verifyVC.forgotPWDto = dataDto
                        navigationController?.pushViewController(verifyVC, animated: true)
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
    
    func rxResetButtonPressed() -> Observable<LoginPostDto> {
        return onClickLogin.asObserver()
    }

    
    private func loginModeDidChange() {
//        accountInputView?.changeInputMode(mode: loginMode)
    }
    func changeInvalidTextWith(dtos:[ErrorsDetailDto])
    {
        accountInputView?.changeInvalidTextColor(with: dtos)
    }
}


