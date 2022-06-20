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
class AuditLoginViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
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
    private let tabbarVC = AuditTabbarViewController()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
        if didAskBioLogin == true 
        {
            bioVerifyCheck()
        }
        if KeychainManager.share.getAuditRememberMeStatus() == true
        {
            if let loginPostDto = KeychainManager.share.getLastAuditAccount(),
               BioVerifyManager.share.usedAuditBIOVeritfy(loginPostDto.account)
            {
                DispatchQueue.main.async { [self] in
                    accountInputView.textField.text = loginPostDto.account
                    passwordInputView.textField.text = loginPostDto.password
                    checkBoxView.isSelected = true
                    checkBoxView.checkType = .checkType
                }
            }else
            {
                //暫時強制寫上
                accountInputView.textField.text = "admin@mundocoin.com"
                passwordInputView.textField.text = "Admin!234"
            }
        }else
        {
            checkBoxView.isSelected = false
            checkBoxView.checkType = .defaultType
            //暫時強制寫上
            accountInputView.textField.text = "admin@mundocoin.com"
            passwordInputView.textField.text = "Admin!234"
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
            goTodoViewController()
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
    func goTodoViewController() {
        let idString = accountInputView.textField.text!
        let password = passwordInputView.textField.text!
        Beans.auditServer.auditAuthentication(with: idString, password: password)
            .subscribeSuccess { [self] (dto) in
                _ = LoadingViewController.dismiss()
                if let data = dto
                {
                    MemberAccountDto.share = MemberAccountDto(account: idString,
                                                              password: password,
                                                              loginMode: .emailPage)
                    _ = KeychainManager.share.setLastAuditAccount(idString)
                    KeychainManager.share.updateAuditAccount(acc: idString,
                                                        pwd: password)
                    BioVerifyManager.share.applyMemberInAuditBIOList(idString)
                    KeychainManager.share.setAuditToken(data.token)
                    let didAskBioLogin = BioVerifyManager.share.didAskAuditBioLogin()
                    showAuditBioConfirmView(didShow: didAskBioLogin)
                }
            }.disposed(by: dpg)
    }
    // Confirm Touch/Face ID
    private func showAuditBioConfirmView(didShow:Bool) {
        if didShow == false
        {
            let popVC =  ConfirmPopupView(iconMode: .nonIcon(["Cancel".localized,"Confirm".localized]),
                                          title: "",
                                          message: "启用脸部辨识或指纹辨识进行登入？") { [weak self] isOK in
                if isOK {
                    let idString = self?.accountInputView.textField.text ?? ""
                    BioVerifyManager.share.applyMemberInAuditBIOList(idString)
                }
                BioVerifyManager.share.setAuditBioLoginSwitch(to: isOK)
                self?.goTOMainVC()
            }
            DispatchQueue.main.async {[self] in
                popVC.start(viewController: self)
            }
            BioVerifyManager.share.setAuditBioLoginAskStateToTrue()
        }else
        {
            goTOMainVC()
        }
    }
    func goTOMainVC()
    {
        DispatchQueue.main.async {
            if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
                print("go ")
                mainWindow.rootViewController = self.tabbarVC
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
                    Toast.show(msg: "验证失败，请输入帐号密码")
                    let popVC = ConfirmPopupView(iconMode: .showIcon("Close"), title: "Warning", message: "验证失败，请输入帐号密码.") { (_) in
                        
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
            if let loginPostDto = KeychainManager.share.getLastAuditAccount(),
               BioVerifyManager.share.usedAuditBIOVeritfy(loginPostDto.account) {
                // 進行臉部或指紋驗證
                BioVerifyManager.share.bioVerify { [self] (success, error) in
                    if !success {
                        DispatchQueue.main.async {[self] in
                        Toast.show(msg: "验证失败，请输入帐号密码")
                        let popVC = ConfirmPopupView(iconMode: .showIcon("Close"), title: "Warning", message: "验证失败，请输入帐号密码.") { (_) in
                            
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
        #if Mundo_PRO
        #elseif Approval_PRO
        #else
        let versionString = Bundle.main.releaseVersionNumber ?? ""
        let buildString = Bundle.main.buildVersionNumber ?? ""
        let version = "\(versionString) b-\(buildString)"
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
}
// MARK: -
// MARK: 延伸
