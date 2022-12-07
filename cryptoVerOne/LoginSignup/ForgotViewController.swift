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
    private var seconds = BuildConfig.HG_NORMAL_COUNT_SECONDS
    private var forgotPasswordMode : ForgotPasswordMode = .emailPage {
        didSet {
        }
    }
    // MARK: -
    // MARK:UI 設定
//    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var sendResetLinkButton: CornerradiusButton!
    private var accountInputView: AccountInputView!
    // MARK: -
    // MARK:Life cycle
    static func instance(mode: ForgotPasswordMode) -> ForgotViewController {
        let vc = ForgotViewController.loadNib()
        vc.forgotPasswordMode = mode
        vc.secondViewDidLoad()
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: -
    // MARK:業務方法
    func secondViewDidLoad()
    {
        setup()
        bindLinkBtn()
        bindAccountView()
//        setupBackgroundView()
        accountInputView?.bindTextfield()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        resetInputView()
    }
    
    func setDefault() {
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
        switch forgotPasswordMode {
        case .emailPage: return "E-mail".localized
        case .phonePage: return "Mobile".localized
        }
    }
    
    func setup() {
        accountInputView = AccountInputView(inputMode: forgotPasswordMode.inputViewMode,
                                            currentShowMode: forgotPasswordMode.forShowMode,
                                            lineColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        view.addSubview(accountInputView!)
        accountInputView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(Themes.inputViewDefaultHeight + Themes.inputViewPasswordHeight)
        }
        view.addSubview(sendResetLinkButton)
        
        sendResetLinkButton.snp.makeConstraints { (make) in
            make.top.equalTo(accountInputView!.snp.bottom).offset(65)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        sendResetLinkButton.setTitle("Send".localized, for: .normal)
        
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
    func getDefaultData() -> [CountryDetail]
    {
        guard let path = Bundle.main.path(forResource: "countries", ofType: "json") else { return CountriesDto().countries}
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let results = try decoder.decode(CountriesDto.self, from:data)
            return results.countries
        } catch {
            print(error)
            return CountriesDto().countries
        }
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
            let phoneCode = accountInputView.accountInputView.mobileCodeLabel.text ?? ""
            let phone = account
            let dto = LoginPostDto(account: account,
                                   password:"",
                                   loginMode: forgotPasswordMode.forLoginMode ,
                                   showMode: forgotPasswordMode.forShowMode,
                                   phoneCode: phoneCode,
                                   phone: phone)
            view.endEditing(true)
            showVerifyVCWithLoginData(dto)
        }
    }

    func showVerifyVCWithLoginData(_ dataDto: LoginPostDto)
    {
        guard let account = accountInputView.accountInputView.textField.text?.lowercased() else {return}
        var accountString = ""
        if dataDto.loginMode == .phonePage , let phoneCode = accountInputView.accountInputView.mobileCodeLabel.text
        {
            accountString = (phoneCode + account)
        }else
        {
            accountString = account
        }
        Beans.loginServer.verificationIDGet(idString: accountString).subscribe { [self] dto in
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
    func changeInvalidTextWith(dtos:[ErrorsDetailDto])
    {
        accountInputView?.changeInvalidTextColor(with: dtos)
    }
}


