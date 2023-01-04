//
//  AuditLoginViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/10/22.
//

import Foundation
import RxCocoa
import RxSwift
import Toaster
import UIKit

public typealias AuthCompletionBlock = (String) -> Void
class AuditLoginViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    var isPopBySubVC = false
    private var isNetWorkConnectIng = false
    private let dpg = DisposeBag()
//    static let share: AuditLoginViewController = AuditLoginViewController.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var accountInputView: InputStyleView!
    @IBOutlet weak var passwordInputView: InputStyleView!
    @IBOutlet weak var checkBoxView: CheckBoxView!
    @IBOutlet weak var loginButton: CornerradiusButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var logoButton : UIButton!
    @IBOutlet weak var middleView: UIView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Themes.grayF7F8FC
        naviBackBtn.isHidden = true
        setupKeyboardNoti()
        setupUI()
        bindTextfield()
        bindLoginButton()
        bindCheckBox()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let didAskBioLogin = BioVerifyManager.share.didAskAuditBioLogin()
        if didAskBioLogin == true ,isPopBySubVC == false
        {
            // 1025 FaceID 功能狀態
            if KeychainManager.share.getFaceIDStatus() == true
            {
                bioVerifyCheck()
            }
        }
        isPopBySubVC = false
        if KeychainManager.share.getAuditRememberMeStatus() == true
        {
            if let loginPostDto = KeychainManager.share.getLastAccountDto(),
               BioVerifyManager.share.usedAuditBIOVeritfy(loginPostDto.account)
            {
                DispatchQueue.main.async { [self] in
                    accountInputView.textField.text = loginPostDto.account
                    passwordInputView.textField.text = loginPostDto.password
                    checkBoxView.isSelected = true
                    checkBoxView.checkType = .checkType
                    accountInputView.textField.sendActions(for: .valueChanged)
                    passwordInputView.textField.sendActions(for: .valueChanged)
                }
            }else
            {
                //暫時強制寫上
                checkBoxView.isSelected = true
                checkBoxView.checkType = .checkType
#if Mundo_PRO || Mundo_STAGE || Approval_PRO || Approval_STAGE
            
#else
                accountInputView.textField.text = "admin@mundocoin.com"
                passwordInputView.textField.text = "Admin!234"
                accountInputView.textField.sendActions(for: .valueChanged)
                passwordInputView.textField.sendActions(for: .valueChanged)
#endif
            }
        }else
        {
            checkBoxView.isSelected = false
            checkBoxView.checkType = .defaultType
            //暫時強制寫上
#if Mundo_PRO || Mundo_STAGE || Approval_PRO || Approval_STAGE
            
#else
                accountInputView.textField.text = "admin@mundocoin.com"
                passwordInputView.textField.text = "Admin!234"
                accountInputView.textField.sendActions(for: .valueChanged)
                passwordInputView.textField.sendActions(for: .valueChanged)
#endif
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        accountInputView.tfMaskView.changeBorderWith(isChoose:false)
        passwordInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func setupKeyboardNoti()
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
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if ((passwordInputView?.textField.isFirstResponder) == true)
            {
                let diffHeight = Views.screenHeight - passwordInputView.frame.maxY
                if diffHeight < (keyboardHeight + 50)
                {
                    let upHeight = (keyboardHeight + 50) - diffHeight
                    if backgroundView.frame.origin.y == Views.topOffset {
                        backgroundView.frame.origin.y = Views.topOffset - upHeight
                    }
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if backgroundView.frame.origin.y != Views.topOffset {
            backgroundView.frame.origin.y = Views.topOffset
         }
    }

    func setupUI()
    {
        accountInputView.setMode(mode: .auditAccount)
        passwordInputView.setMode(mode: .auditPassword)
        middleView.applyCornerAndShadow(radius: 12)
    }
    func bindTextfield()
    {
        accountInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            accountInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            passwordInputView.tfMaskView.changeBorderWith(isChoose:false)
        }.disposed(by: dpg)
        passwordInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            accountInputView.tfMaskView.changeBorderWith(isChoose:false)
            passwordInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)

        let isAccountValid = accountInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard let acc = str else { return false  }
                return RegexHelper.match(pattern:.mail , input: acc)
        }
        let isPWValid = passwordInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:.password, input: acc)
        }
        isAccountValid.skip(1).bind(to: accountInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isPWValid.skip(1).bind(to: passwordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)

        Observable.combineLatest(isAccountValid, isPWValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func bindLoginButton()
    {
        loginButton.rx.tap.subscribeSuccess { [self](_) in
            Log.v("Audit登入")
            loginButton.isEnabled = false
            if isNetWorkConnectIng != true
            {
                isNetWorkConnectIng = true
                goTodoViewController()
            }
        }.disposed(by: dpg)
    }
    func bindCheckBox()
    {
        checkBoxView.rxCheckBoxPassed().subscribeSuccess { isSelect in
            Log.v("isselect \(isSelect)")
            KeychainManager.share.saveAuditRememberMeStatus(isSelect)
        }.disposed(by: dpg)
    }
    func getTabbarVC() -> AuditTabbarViewController? {
        return UIApplication.topViewController() as? AuditTabbarViewController
    }
    func showTwoFAVC(complete:AuthCompletionBlock? = nil)
    {
        isPopBySubVC = true
        // 判斷是否有綁定過2FA
        // 沒綁過
//        let emailString = accountInputView.textField.text!
//        let goAuthVC = AuditBindTwoFAViewController.instance(emailString: emailString)
//        _ = self.navigationController?.pushViewController(goAuthVC, animated: true)
        // 有綁過
        let emailString = accountInputView.textField.text!
        let goAuthVC = AuditTwoFACheckViewController.instance(emailString: emailString)
        goAuthVC.rxSubmitClick().subscribeSuccess { stringValue in
            if let completeBlock = complete
            {
                completeBlock(stringValue)
            }
        }.disposed(by: dpg)
        _ = self.navigationController?.pushViewController(goAuthVC, animated: true)
    }
    func goTodoViewController() {
        // 2FA 先拿掉
//        showTwoFAVC(complete: { [self] stringValue in
//            Log.v("2FA Code: \(stringValue)")
//            let idString = accountInputView.textField.text!
//            let password = passwordInputView.textField.text!
//            Beans.auditServer.auditAuthentication(with: idString, password: password)
//                .subscribeSuccess { [self] (dto) in
//                    _ = LoadingViewController.dismiss()
//                    if let data = dto
//                    {
//                        MemberAccountDto.share = MemberAccountDto(account: idString,
//                                                                  password: password,
//                                                                  loginMode: .emailPage)
//                        _ = KeychainManager.share.setLastAccount(idString)
//                        KeychainManager.share.updateAccount(acc: idString,
//                                                            pwd: password)
//                        BioVerifyManager.share.applyMemberInAuditBIOList(idString)
//                        KeychainManager.share.setToken(data.token)
//                        let didAskBioLogin = BioVerifyManager.share.didAskAuditBioLogin()
//                        showAuditBioConfirmView(didShow: didAskBioLogin)
//                    }
//                }.disposed(by: dpg)
//        })
        let idString = accountInputView.textField.text!
        let password = passwordInputView.textField.text!
        Beans.auditServer.auditAuthentication(with: idString, password: password)
            .subscribe { [self] (dto) in
                _ = LoadingViewController.dismiss()
                if let data = dto
                {
                    MemberAccountDto.share?.account = idString
                    MemberAccountDto.share?.password = password
                    MemberAccountDto.share?.loginMode = .emailPage
                    _ = KeychainManager.share.setLastAccount(idString)
                    KeychainManager.share.updateAccount(acc: idString,
                                                        pwd: password)
                    BioVerifyManager.share.applyMemberInAuditBIOList(idString)
                    KeychainManager.share.setToken(data.token)
                    var didAskBioLogin = true
                    // 1025 FaceID 功能狀態
                    if KeychainManager.share.getFaceIDStatus() == true
                    {
                        didAskBioLogin = BioVerifyManager.share.didAskAuditBioLogin()
                    }
                    showAuditBioConfirmView(didShow: didAskBioLogin)
                }
            } onError: { [self] error in
                isNetWorkConnectIng = false
                if let error = error as? ApiServiceError {
                    ErrorHandler.show(error: error)
                }
            }.disposed(by: disposeBag)
    }
    // Confirm Touch/Face ID
    private func showAuditBioConfirmView(didShow:Bool) {
        if didShow == false
        {
            let popVC =  ConfirmPopupView(iconMode: .nonIcon(["Cancel".localized,"Confirm".localized]),
                                          title: "",
                                          message: "Enable biometric ID?") { [weak self] isOK in
                if isOK {
                    let idString = self?.accountInputView.textField.text ?? ""
                    BioVerifyManager.share.applyMemberInAuditBIOList(idString)
                }
                BioVerifyManager.share.setAuditBioLoginSwitch(to: isOK)
                self?.goToAuditMainVC()
            }
            DispatchQueue.main.async {[self] in
                popVC.start(viewController: self)
            }
            BioVerifyManager.share.setAuditBioLoginAskStateToTrue()
        }else
        {
            goToAuditMainVC()
        }
    }
    func goToAuditMainVC()
    {
//         socket
        SocketIOManager.sharedInstance.establishConnection()
        isNetWorkConnectIng = false
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
        {
            DispatchQueue.main.async {
                appDelegate.freshToken()
                mainWindow.rootViewController = AuditTabbarViewController()
                mainWindow.makeKeyAndVisible()
            }
        }
    }
    
    private func bioVerifyCheck(isDev : Bool = false) {
        if isDev
        {
            // 進行臉部或指紋驗證
            BioVerifyManager.share.bioVerify { [self] (success, error) in
                if !success {
                    DispatchQueue.main.async {[self] in
//                    Toast.show(msg: "验证失败，请输入帐号密码")
                    let popVC = ConfirmPopupView(iconMode: .showIcon("Close"), title: "Warning", message: "Verification failed, please enter account password.") { (_) in
                        
                    }
                        popVC.start(viewController: self)
                    }
                    return
                }
                if error != nil {
                    Toast.show(msg: "验证失败：\(error!.localizedDescription)")
                    return
                }
            }
        }else
        {
            if !BioVerifyManager.share.auditBioLoginSwitchState() { return }
            if let loginPostDto = KeychainManager.share.getLastAccountDto(),
               BioVerifyManager.share.usedAuditBIOVeritfy(loginPostDto.account) {
                // 進行臉部或指紋驗證
                BioVerifyManager.share.bioVerify { [self] (success, error) in
                    if !success {
                        DispatchQueue.main.async {[self] in
//                        Toast.show(msg: "验证失败，请输入帐号密码")
                        let popVC = ConfirmPopupView(iconMode: .showIcon("Close"), title: "Warning", message: "Verification failed, please enter account password.") { (_) in
                            
                        }
                            popVC.start(viewController: self)
                        }
//                        return
                    }
                    if error != nil {
                        Toast.show(msg: "验证失败：\(error!.localizedDescription)")
                        return
                    }
                    DispatchQueue.main.async { [self] in
                        accountInputView.textField.text = loginPostDto.account
                        passwordInputView.textField.text = loginPostDto.password
                        goTodoViewController()
                    }
                }
            } else {
                print("manual login.")
            }
        }
    }
    @IBAction func changeDomain(_ sender: Any) {
        #if Mundo_PRO || Approval_PRO || Approval_STAGE || Mundo_STAGE
        #else
        let versionString = Bundle.main.releaseVersionNumber ?? ""
        let buildString = Bundle.main.buildVersionNumber ?? ""
        let version = "A \(versionString).\(buildString)"
        var envirment = ""
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            switch KeychainManager.share.getDomainMode()
            {
            case .AuditStage:
                _ = KeychainManager.share.setDomainMode(.AuditDev)
                appdelegate.domainMode = .AuditDev
                envirment = "AuditDev"
            case .AuditDev:
                _ = KeychainManager.share.setDomainMode(.AuditQa)
                appdelegate.domainMode = .AuditQa
                envirment = "AuditQa"
            case .AuditQa:
                _ = KeychainManager.share.setDomainMode(.AuditPro)
                appdelegate.domainMode = .AuditPro
                envirment = "AuditPro"
            case .AuditPro:
                _ = KeychainManager.share.setDomainMode(.AuditStage)
                appdelegate.domainMode = .AuditStage
                envirment = "AuditStage"
            default : break
            }
     
        }
        Toast.show(msg: "版本號 : \(version)\n切換到 \(envirment)\n 域名:\(BuildConfig.Domain)")
        BuildConfig().resetDomain()
        ApiService.host = BuildConfig.MUNDO_SITE_API_HOST
        #endif
    }
    override var preferredStatusBarStyle:UIStatusBarStyle {
        if #available(iOS 13.0, *) {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return .darkContent
#else
            return .darkContent
#endif
        } else {
            return .default
        }
    }
}
// MARK: -
// MARK: 延伸
