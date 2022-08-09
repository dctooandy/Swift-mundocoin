//
//  LoginSignupViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.

import UIKit
import Parchment
import RxSwift
import Toaster
import AVFoundation
import AVKit
import ReCaptcha

enum ShowMode {
    case loginEmail
    case loginPhone
    case signupEmail
    case signupPhone
    case forgotPW
    
    var accountInputMode:InputViewMode {
        switch self {
        case .loginEmail,.signupEmail:
            return .email
        case .forgotPW:
            return .forgotPW
        case .signupPhone,.loginPhone:
            return .phone
        }
    }
}
class LoginSignupViewController: BaseViewController {
    // MARK:業務設定
    fileprivate let loginPageVC = LoginPageViewController()
    static let share: LoginSignupViewController = LoginSignupViewController.loadNib()
    /// 显示注册或登入页面
    private var currentShowMode: ShowMode = .loginEmail {
        didSet {
            resetUI()
            setNavigationLeftView(isForgotView: currentShowMode == .forgotPW ? true : false)
            loginPageVC.reloadPageMenu(currentMode: currentShowMode)
        }
    }
    private var shouldVerify = true
    private var route: SuccessViewAction.Route? = nil
    private var backGroundVideoUrl: URL? = nil
    private var willShowAgainFromVerifyVC = false
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
//    var recaptchaVC = RecaptchaViewController.loadNib()
    var verifyVC : VerifyViewController!
    private lazy var switchButton:UIButton = {
        let rightBtn = UIButton()
        rightBtn.setTitle("Sign Up".localized, for:.normal)
        rightBtn.setTitleColor(#colorLiteral(red: 0.106, green: 0.145, blue: 0.349, alpha: 1.0), for: .normal)
        rightBtn.titleLabel?.font = Fonts.PlusJakartaSansSemiBold(20)
        rightBtn.addTarget(self, action: #selector(switchViewAction), for: .touchUpInside)
        return rightBtn
    }()
    private lazy var coverButton:UIButton = {
        let coverButton = UIButton()
        coverButton.setTitle("".localized, for:.normal)
        coverButton.addTarget(self, action: #selector(changeDomain), for: .touchUpOutside)
        return coverButton
    }()
    private lazy var logoView:UIView = {
        let logoView = UIView()
        logoView.frame = CGRect(x: 0, y: 0, width: 200.0, height: 40)
        logoView.backgroundColor = .clear
        return logoView
    }()
    private lazy var backToButton:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(backToLoginView), for:.touchUpInside)
        return btn
    }()
    private var successView: SignupSuccessView?
    private let tabbarVC = TabbarViewController()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginPageVC()
        bindLoginPageVC()
        setupLeftLogoView()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addDateSelectedButton()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let didAskBioLogin = BioVerifyManager.share.didAskBioLogin()
        if didAskBioLogin == true , willShowAgainFromVerifyVC == false
        {
            // 暫時 關掉BioView FaceID
//            bioVerifyCheck()
        }
        willShowAgainFromVerifyVC = false
//        VideoManager.share.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        VideoManager.share.pause()
    }
    // MARK: -
    // MARK:業務方法
    private func setupLoginPageVC() {
        addChild(loginPageVC)
        view.insertSubview(loginPageVC.view, aboveSubview: backgroundImageView)
        loginPageVC.view.snp.makeConstraints({ (make) in
            make.top.equalTo(self.topLabel.snp.bottom).offset(35)
            make.left.bottom.right.equalToSuperview()
        })
    }
    private func bindLoginPageVC() {
        // 登入
        loginPageVC.rxLoginBtnClick().subscribeSuccess { [weak self] (dto) in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
#if Approval_PRO || Approval_DEV || Approval_STAGE
            strongSelf.goApprovalViewController()
#else
            // 要先檢查帳號存在,API 還沒好
            // 推向传送验证码VC
            strongSelf.showVerifyVCWithLoginData(dto)
            // 圖形驗證 : 封印
            //            strongSelf.showImageVerifyView(dto)
#endif
        }.disposed(by: disposeBag)
        
        // 註冊
        loginPageVC.rxSignupBtnClick().subscribeSuccess { [weak self] (dto) in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
            // 要先檢查帳號存在,API 還沒好
            // 圖形驗證
            strongSelf.showImageVerifyView(dto)
        }.disposed(by: disposeBag)
        
 
        // 發送驗證碼
//        loginPageVC.rxVerifyCodeBtnClick().subscribeSuccess { [weak self] (phone) in
//            self?.view.endEditing(true)
//            self?.sendVerifyCodeForPhone(phone)
//        }.disposed(by: disposeBag)
        
        // 發送reset 密碼 // forgot頁面已經不再 paging VC
//        loginPageVC.rxResetPWBtnClick().subscribeSuccess { [weak self] (dto) in
//            self?.view.endEditing(true)
//            self?.sendResetLinkForEmail(dto)
//        }.disposed(by: disposeBag)
        
        // 忘記密碼
        loginPageVC.rxForgetBtnClick().subscribeSuccess { [weak self] in
            self?.view.endEditing(true)
            self?.showForgetPasswordVC()
        }.disposed(by: disposeBag)
    }
    func setupLeftLogoView()
    {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoView)
        let iconView = UIImageView(image: #imageLiteral(resourceName: "mundoLogo"))
        logoView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(38)
            make.height.equalTo(38)
        }
        #if Approval_PRO || Approval_DEV || Approval_STAGE
        let label = UILabel(title: "Approval", textColor: .black)
        label.font = Fonts.PlusJakartaSansMedium(24)
        logoView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconView.snp.trailing).offset(10)
            make.width.equalTo(138)
            make.height.equalTo(33)
        }
        #else
        let textView = UIImageView(image: #imageLiteral(resourceName: "textMundoCoin"))
        textView.contentMode = .scaleAspectFit
        logoView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconView.snp.trailing).offset(10)
            make.width.equalTo(138)
            make.height.equalTo(33)
        }
        #endif
        logoView.addSubview(coverButton)
        coverButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    private func setupUI() {
        setNavigationLeftView(isForgotView: false)
        resetUI()
        view.backgroundColor = Themes.grayF4F7FE
        topLabel.textColor = #colorLiteral(red: 0.169, green: 0.212, blue: 0.455, alpha: 1.0)
    }
}

// MARK: -
// MARK: 延伸
extension LoginSignupViewController {
    private func addDateSelectedButton() {
        if currentShowMode !=  .forgotPW
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: switchButton)
            backToButton.isHidden = true
        }
    }
    @objc func switchViewAction() {
        self.changeLoginState()
    }
    
    @objc func backToLoginView(isAnimation : Bool = true)
    {
        currentShowMode = .loginEmail
    }
    
    @objc func goToWalletVC()
    {
        self.goWalletViewController()
    }
    @objc func changeDomain()
    {
        #if Mundo_PRO || Mundo_STAGE
        #elseif Approval_PRO
        #else
        let versionString = Bundle.main.releaseVersionNumber ?? ""
        let buildString = Bundle.main.buildVersionNumber ?? ""
        let version = "\(versionString) b-\(buildString)"
        var envirment = ""
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            if KeychainManager.share.getDomainMode() == .Stage
            {
                _ = KeychainManager.share.setDomainMode(.Dev)
                appdelegate.domainMode = .Dev
                envirment = "Dev"
            }else if KeychainManager.share.getDomainMode() == .Dev
            {
                _ = KeychainManager.share.setDomainMode(.Qa)
                appdelegate.domainMode = .Qa
                envirment = "Qa"
            }else if KeychainManager.share.getDomainMode() == .Qa
            {
                _ = KeychainManager.share.setDomainMode(.Pro)
                appdelegate.domainMode = .Pro
                envirment = "Pro"
            }else
            {
                _ = KeychainManager.share.setDomainMode(.Stage)
                appdelegate.domainMode = .Stage
                envirment = "Stage"
            }
        }
        Toast.show(msg: "版本號 : \(version)\n切換到 \(envirment)\n 域名:\(BuildConfig.Domain)")
        BuildConfig().resetDomain()
        ApiService.host = BuildConfig.MUNDO_SITE_API_HOST
        #endif
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
            if currentShowMode != .loginEmail &&
                currentShowMode != .loginPhone { return }
            if !BioVerifyManager.share.bioLoginSwitchState() { return }
            if let loginPostDto = KeychainManager.share.getLastAccount(),
               BioVerifyManager.share.usedBIOVeritfy(loginPostDto.account) {
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
                    DispatchQueue.main.async {
                    let dto = LoginPostDto(account: loginPostDto.account, password: loginPostDto.password,loginMode: loginPostDto.loginMode ,showMode: .loginEmail)
                        self.showVerifyVCWithLoginData(dto)
                    }
                }
            } else {
                print("manual login.")
            }
        }
    }
    
    func showMode(_ showMode: ShowMode) -> LoginSignupViewController {
        self.currentShowMode = showMode
        return self
    }
    
    func showVerifyVCWithLoginData(_ dataDto: LoginPostDto)
    {
        
        Beans.loginServer.verificationIDPost(idString: dataDto.account , pwString: dataDto.password).subscribe { [self] dto in
            Log.v("帳號有註冊過")
            willShowAgainFromVerifyVC = true
            // 暫時改為直接推頁面
            verifyVC = VerifyViewController.loadNib()
            verifyVC.loginDto = dataDto
            navigationController?.pushViewController(verifyVC, animated: true)
        } onError: { [self] error in
            if let error = error as? ApiServiceError {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    
                    if status == "400"
                    {
                        loginPageVC.loginViewControllers.first!.accountInputView?.passwordInputView.changeInvalidLabelAndMaskBorderColor(with: reason)
                    }else if status == "404"
                    {
                        loginPageVC.loginViewControllers.first!.accountInputView?.passwordInputView.changeInvalidLabelAndMaskBorderColor(with: reason)
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
    func showVerifyVCWithSignUpData(_ dataDto: SignupPostDto)
    {
        willShowAgainFromVerifyVC = true
        // 暫時改為直接推頁面
        verifyVC = VerifyViewController.loadNib()
        verifyVC.signupDto = dataDto
        navigationController?.pushViewController(verifyVC, animated: true)
    }
 
    // MARK: 忘記密碼
    private func showForgetPasswordVC() {
        Log.v("忘記密碼")
//        self.present(ForgetPasswordViewController(), animated: true, completion: nil)
        // 原本方式
//        currentShowMode = .forgotPW
        // 新改為推送

        let accForgot = ForgotViewController.instance(mode: .emailPage)
        accForgot.rxResetButtonPressed().subscribeSuccess { [self](dto) in
            view.endEditing(true)
            // 推向传送验证码VC
            showVerifyVCWithLoginData(dto)
        }.disposed(by: disposeBag)
        self.navigationController?.pushViewController(accForgot, animated: true)
    }
    
    // Confirm Touch/Face ID
    private func showBioConfirmView() {
        let popVC =  ConfirmPopupView(iconMode: .nonIcon(["Cancel".localized,"Confirm".localized]),
                                      title: "",
                                      message: "启用脸部辨识或指纹辨识进行登入？") { [weak self] isOK in
            if isOK {
                guard let acc = MemberAccountDto.share?.account else { return }
                BioVerifyManager.share.applyMemberInBIOList(acc)
            }
            BioVerifyManager.share.setBioLoginSwitch(to: isOK)
            self?.navigateToRouter(showBioView: false, route: .wallet)
        }
        DispatchQueue.main.async {[self] in
            popVC.start(viewController: self)
        }
    }
    // 登入
    func gotoLoginAction(with idString:String ,
                         password:String ,
                         verificationCode:String = "",
                         loginDto : LoginPostDto? = nil,
                         signupDto : SignupPostDto? = nil)
    {
        if let loginData = loginDto ,loginData.currentShowMode == .forgotPW
        {
            Log.v("忘記密碼驗證完畢,輸入密碼")
            verifyVC.directToResetPWVC(verificationCode)
        }else
        {
            Beans.loginServer.authentication(with: idString, password: password, verificationCode: verificationCode).subscribe { [self]authDto in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss()
                    verifyVC.timer?.invalidate()
                    if let data = authDto
                    {
                        if let loginData = loginDto
                        {
                            directToNextPage(authDto: data ,loginDto: loginData)
                        }else if let signupData = signupDto
                        {
                            directToNextPage(authDto: data ,signupDto: signupData)
                        }
                    }
                }
            } onError: { [self] error in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss()
                    verifyVC.timer?.invalidate()
                    if let error = error as? ApiServiceError
                    {
                        switch error {
                        case .errorDto(let dto):
                            let reason = dto.reason
                            if reason == "CODE_MISMATCH" || reason == "CODE_NOT_FOUND"
                            {
                                verifyVC.verifyInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                            }
                        case .noData:
                            Log.v("登入返回沒有資料")
                        default:
                            ErrorHandler.show(error: error)
                        }
                    }
                }
            }.disposed(by: disposeBag)
        }
    }
    func gotoSignupAction(code:String ,
                          email:String = "" ,
                          password:String ,
                          phone:String = "",
                          verificationCode : String,
                          signupDto : SignupPostDto)
    {
        Beans.loginServer.signUPRegistration(code: code, email: email, password: password, phone: phone, verificationCode: verificationCode).subscribe { [self]dto in
            // 消除Loading
            _ = LoadingViewController.dismiss()
            if let regisDto = dto{
                RegistrationDto.share = regisDto
                var idString = ""
                if email.isEmpty
                {
                    idString = phone
                }else
                {
                    idString = email
                }
                // 去登入
                gotoLoginAction(with: idString, password: password,signupDto: signupDto)
            }
        } onError: { [self] error in
            _ = LoadingViewController.dismiss()
            if let error = error as? ApiServiceError
            {
                switch error {
                case .errorDto(let dto):
                    verifyVC.verifyInputView.changeInvalidLabelAndMaskBorderColor(with: dto.reason)
                case .noData:
                    Log.v("註冊返回沒有資料")
                default:
                    ErrorHandler.show(error: error)
                }
            }
        }.disposed(by: disposeBag)
    }
    func directToNextPage(authDto:AuthenticationDto,
                          loginDto : LoginPostDto? = nil,
                          signupDto : SignupPostDto? = nil)
    {
        // 登入 驗證完畢直接登入
        // 註冊 驗證完畢跳出國碼選擇
        if let loginData = loginDto
        {
            if loginData.currentShowMode != .forgotPW
            {
                Log.v("登入驗證完畢,直接登入")
                Log.v("得到 Token 轉去 Login ")
                popVC()
                directToSaveDataAndLogin(authDto:authDto,loginDto: loginData)
            }
//            else
//            {
//                Log.v("忘記密碼驗證完畢,輸入密碼")
//                verifyVC.directToResetPWVC(<#T##verifyString: String##String#>)
//            }
        }else if let signupData = signupDto
        {
            Log.v("註冊驗證完畢,直接登入")
            popVC()
            directToSaveDataAndLogin(authDto:authDto,signupDto: signupData)
            // 目前不用選擇國別
            //                Log.v("註冊驗證完畢,國碼選擇")
            //                idVerifiVC.isModalInPopover = true
            //                idVerifiVC.rxSkipAction().subscribeSuccess { (_) in
            //                    if let dto = self.signupDto
            //                    {
            //                        LoginSignupViewController.share.signup(dto: dto)
            //                    }
            //                }.disposed(by: dpg)
            //                idVerifiVC.rxGoAction().subscribeSuccess { [self](countryString) in
            //                    if let dto = self.signupDto
            //                    {
            //                        self.dismiss(animated: true) {
            //                            popVC()
            //                            LoginSignupViewController.share.signup(dto: dto)
            //                        }
            //                    }
            //                }.disposed(by: dpg)
            //                self.present(idVerifiVC, animated: true) {
            //                }
        }
    }
    func directToSaveDataAndLogin(authDto:AuthenticationDto,
                                  loginDto : LoginPostDto? = nil,
                                  signupDto : SignupPostDto? = nil)
    {
        // 開始倒數
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.startToCountDown()
        }
        if let dto = loginDto
        {
            MemberAccountDto.share = MemberAccountDto(account: dto.account,
                                                      password: dto.password,
                                                      loginMode: dto.loginMode)
            KeychainManager.share.setLastAccount(dto.account)
            KeychainManager.share.updateAccount(acc: dto.account,
                                                pwd: dto.password)
            BioVerifyManager.share.applyMemberInBIOList(dto.account)
        }
        if let dto = signupDto
        {
            MemberAccountDto.share = MemberAccountDto(account: dto.account,
                                                      password: dto.password,
                                                      loginMode: dto.signupMode)
            KeychainManager.share.saveAccPwd(acc: dto.account,
                                             pwd: dto.password,
                                             tel: dto.signupMode == .phonePage ? dto.account: "")
            KeychainManager.share.setLastAccount(dto.account)
            BioVerifyManager.share.applyMemberInBIOList(dto.account)
        }
        let didAskBioLogin = BioVerifyManager.share.didAskBioLogin()
        let showBioView = !didAskBioLogin
        // 暫時 關掉BioView FaceID
        handleLoginSuccess(showLoadingView: false,
                           showBioView: false,
                           route: .wallet)
//        handleLoginSuccess(showLoadingView: false,
//                           showBioView: showBioView,
//                           route: .wallet)
    }
    
    func postPushDevice() {
        //        guard let regID = JPushManager.share.registerID, let apnsToken = JPushManager.deviceToken else { return }
        //        Beans.baseServer.jpsuh(apnsToken: apnsToken, jpushID: regID).subscribeSuccess().disposed(by: disposeBag)
    }
    
    func handleLoginSuccess(showLoadingView: Bool, showBioView: Bool, route: SuccessViewAction.Route = .main) {
        //        WalletDto.update()
        if showLoadingView {
            LoadingViewController.action(mode: .success, title: "登入成功")
                .subscribeSuccess({ [weak self] in
                    self?.navigateToRouter(showBioView: showBioView,
                                           route: route)
                }).disposed(by: disposeBag)
            return
        }
        _ = LoadingViewController.dismiss()
        navigateToRouter(showBioView: showBioView,
                         route: route)
    }
    
    func navigateToRouter(showBioView: Bool, route: SuccessViewAction.Route = .main , isDev : Bool = true) {
        if showBioView {  // 第一次登入，詢問是否要用臉部或指紋驗證登入
            showBioConfirmView()
            if isDev
            {
                BioVerifyManager.share.applyLogedinAccount("test")
                BioVerifyManager.share.setBioLoginAskStateToTrue()
            }else
            {
                BioVerifyManager.share.applyLogedinAccount(MemberAccountDto.share!.account)
                BioVerifyManager.share.setBioLoginAskStateToTrue()
            }
        } else {
            if DeepLinkManager.share.navigation != .none {
                //                goMainViewController()
                goWalletViewController()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    DeepLinkManager.share.navigation.toTargetVC()
                    DeepLinkManager.share.navigation = .none
                }
                return
            }
            
            switch route {
            case .main: goMainViewController()
            case .personal: goPersonalViewController()
            case .member : goMember()
            case .wallet: goWalletViewController()
            }
        }
    }
    
    func setLoginPageToDefault() {
        DispatchQueue.main.async {[weak self] in
            self?.loginPageVC.setVerifyCodeBtnToDefault()
        }
    }

//    func signupSuccess(dto: SignupPostDto, res: SignupDto) {
//        DispatchQueue.main.async {
//            if dto.signupMode == .phonePage {
//                guard let acc = res.account, let pwd = res.password else { return }
//                KeychainManager.share.saveAccPwd(acc: acc,
//                                                 pwd: pwd,
//                                                 tel: dto.account)
//
//                self.showSignupSuccessView(acc: acc,
//                                           pwd: pwd,
//                                           mode: dto.signupMode)
//                return
//            }
//            KeychainManager.share.saveAccPwd(acc: dto.account,
//                                             pwd: dto.password,
//                                             tel: "")
//            self.showSignupSuccessView(acc: dto.account,
//                                       pwd: dto.password,
//                                       mode: dto.signupMode)
//        }
//    }
    
    // MARK: - ViewController navigation
    func changeLoginState() {// 登入註冊頁面
        //        isLogin = !isLogin
        for vc in loginPageVC.loginViewControllers {
            vc.resetInputView()
        }
        for vc in loginPageVC.signupViewControllers {
            vc.resetInputView()
        }
//        for vc in loginPageVC.forgotViewControllers {
//            vc.resetInputView()
//        }
        currentShowMode = ((currentShowMode == .loginEmail) ? .signupEmail : .loginEmail)
    }
    
    func goMainViewController() {
        tabbarVC.selected(0)
        //        tabbarVC.mainPageVC.shouldFetchGameType = true
        let betleadMain = BetleadNavigationController(rootViewController: tabbarVC)
        DispatchQueue.main.async {
            if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
                print("go main")
                mainWindow.rootViewController = betleadMain
                mainWindow.makeKeyAndVisible()
            }
        }
    }
    
    func goPersonalViewController() {
        //        tabbarVC.mainPageVC.shouldFetchGameType = true
        let betleadMain = BetleadNavigationController(rootViewController:tabbarVC)
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            print("go personal")
            mainWindow.rootViewController = betleadMain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabbarVC.selected(3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    //                   UIApplication.topViewController()?.navigationController?.pushViewController(SecurityViewController.loadNib(), animated: true)
                })
            }
        }
    }
    
    func goMember() {
        //        tabbarVC.mainPageVC.shouldFetchGameType = true
        let betleadMain = BetleadNavigationController(rootViewController:tabbarVC)
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            print("go Member")
            mainWindow.rootViewController = betleadMain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabbarVC.selected(3)
                
            }
        }
    }
    
    func goWalletViewController() {
        // socket
        SocketIOManager.sharedInstance.establishConnection()
        let walletVC = WalletViewController.loadNib()
        let walletNavVC = MDNavigationController(rootViewController: walletVC)
        
        //        let betleadMain = BetleadNavigationController(rootViewController: tabbarVC)
        DispatchQueue.main.async {
            if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
                Log.v("go wallet")
                mainWindow.rootViewController = walletNavVC
                mainWindow.makeKeyAndVisible()
                Toast.show(msg: "Welcome to Mundocoin".localized)
            }
        }
    }
    func goApprovalViewController() {
        let approvalVC = ApprovalMainViewController.share
        let approvalNavVC = MDNavigationController(rootViewController: approvalVC)

        DispatchQueue.main.async {
            if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
                Log.v("Approval")
                mainWindow.rootViewController = approvalNavVC
                mainWindow.makeKeyAndVisible()
                Toast.show(msg: "Welcome to Approval App".localized)
            }
        }
    }
    //MARK: - 註冊成功頁面
    func showSignupSuccessView(acc: String, pwd: String, mode: LoginMode) {
        // 目前不顯示註冊成功
        //        successView = SignupSuccessView.loadNib()
        //        successView?.account = acc
        //        successView?.password = pwd
        //        successView?.setup(title: mode.signupSuccessTitles().title,
        //                          buttonTitle: mode.signupSuccessTitles().doneButtonTitle,
        //                          showAccount: mode.signupSuccessTitles().showAccount)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //        view.addSubview(successView!)
        //        successView?.snp.makeConstraints { (make) in
        //            make.edges.equalToSuperview()
        //        }
        //        bindSignupSuccessView()
    }
    
    func removeSuccessView() {
        successView?.removeFromSuperview()
        successView = nil
    }
    
    private func showImageVerifyView(_ postDto: Any) {
        // 顯示本地滑塊驗證
        //        let imageVerifyView = ImageVerifyView()
        //        self.view.addSubview(imageVerifyView)
        //        imageVerifyView.snp.makeConstraints { (make) in
        //            make.edges.equalToSuperview()
        //        }
        //
        //        imageVerifyView
        //            .rxVerifySuccess()
        //            .subscribeSuccess { [weak self] (success) in
        //                if let dto = postDto as? SignupPostDto {
        //                    // 發送註冊以及驗證碼
        //                    self?.sendVerifyCodeForEmailSignup(dto)
        //                } else if let dto = postDto as? LoginPostDto {
        //                    self?.login(dto: dto, checkBioList: dto.loginMode == .emailPage ,route: .wallet)
        //                }
        //                imageVerifyView.removeFromSuperview()
        //            }.disposed(by: disposeBag)
        // 顯示 Google Recaotcha 驗證
        let recaptchaVC = RecaptchaViewController.loadNib()
        recaptchaVC.rxSuccessClick().subscribeSuccess { [self]tokenString in
            if !tokenString.isEmpty
            {
                if let dto = postDto as? SignupPostDto {
                    // 開啟驗證頁面
                    showVerifyVCWithSignUpData(dto)
                }
            }
        }.disposed(by: disposeBag)
        self.navigationController?.pushViewController(recaptchaVC, animated: true)
    }
    

    func setNavigationLeftView(isForgotView:Bool)
    {
        if isForgotView
        {
            self.backToButton.isHidden = false
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backToButton)
        }else
        {
            self.backToButton.isHidden = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoView)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(Views.topOffset + 12.0)
        }
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
    private func resetUI() {

#if Approval_PRO || Approval_DEV || Approval_STAGE
        topLabel.text = "Log in to Approval".localized
        switchButton.isHidden = true
        backToButton.isHidden = true
#else
        switch currentShowMode {
        case .loginEmail,.loginPhone:
            //            fetchBackgroundVideo()
            switchButton.setTitle("Sign Up".localized, for: .normal)
            topLabel.text = "Log in to Mundocoin".localized
            switchButton.isHidden = false
            backToButton.isHidden = true
        case .signupEmail,.signupPhone:
            switchButton.setTitle("Log In".localized, for: .normal)
            topLabel.text = "Create Your Account".localized
            switchButton.isHidden = false
            backToButton.isHidden = true
        case .forgotPW:
            switchButton.setTitle("".localized, for: .normal)
            topLabel.text = "Forgot password".localized
            switchButton.isHidden = true
            backToButton.isHidden = false
        }
#endif
    }
    
//    private func updateBottomView() {
//        if isLogin {
//            let top = Views.isIPhoneWithNotch() ? topOffset(555/812) : topOffset(589/812)
//            bottomView.snp.remakeConstraints { (make) in
//                make.top.equalToSuperview().offset(top)
//                make.centerX.equalToSuperview()
//            }
//            return
//        }
//        bottomView.snp.remakeConstraints { (make) in
//            make.bottom.equalToSuperview().offset(-topOffset(24/812))
//            make.centerX.equalToSuperview()
//        }
//    }
    // MARK: Login Video
    private func fetchLoginVideofromLocal() {
        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeUrl = baseUrl.appendingPathComponent("loginVideo.mp4")
        if FileManager.default.fileExists(atPath: storeUrl.path) {
            backGroundVideoUrl = storeUrl
        } else {
            //            backGroundVideoUrl = URL(string: BuildConfig.LOGIN_VIDEO_URL)
        }
    }
    func fetchBackgroundVideo() {
        print("fetch bg video")
        if backGroundVideoUrl != nil {
            DispatchQueue.main.async { [weak self] in
                self?.setupLoginVideo()
            }
            return
        }
        
        let lastUpdateDate = UserDefaults.Verification.string(forKey: .loginVideoUpdateDate)
        //        Beans.bannerServer.loginVideo().subscribe(onSuccess: { [weak self] (dto) in
        //            guard let urlString = dto?.bannerVideoMobile, !urlString.isEmpty, let updaateDate = dto?.bannerUpdatedAt else {
        //                    self?.fetchLoginVideofromLocal()
        //                    self?.setupLoginVideo()
        //                    return
        //            }
        //            self?.backGroundVideoUrl = URL(string: urlString)
        //            if !updaateDate.isEmpty && updaateDate == lastUpdateDate {
        //                print("get login video from local url")
        //                self?.fetchLoginVideofromLocal()
        //            } else {
        //                print("get login video from api url")
        //                self?.backGroundVideoUrl = URL(string: urlString)
        //                Beans.bannerServer.fetchLoginVideoData(urlString: urlString, updateDate: updaateDate)
        //            }
        //            self?.setupLoginVideo()
        //        }, onError: { [weak self] (error) in
        //            print("fetch login video error")
        //            self?.fetchLoginVideofromLocal()
        //            self?.setupLoginVideo()
        //        }).disposed(by: disposeBag)
    }
    private func setupLoginVideo() {
//        let videoManager = VideoManager.share
//        if let _ = videoManager.videoLayer() {
//            videoManager.addVideoLayer(view: view)
//            videoManager.play()
//            return
//        }
//        let url = backGroundVideoUrl != nil ? backGroundVideoUrl! : URL(string: BuildConfig.LOGIN_VIDEO_URL)!
//        if let _ = videoManager.videoFrom(url: url) {
//             videoManager.addVideoLayer(view: view)
//        }
    }
    func goADPopupView(urlStr: String) {
        let betleadMain = BetleadNavigationController(rootViewController:tabbarVC)
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            mainWindow.rootViewController = betleadMain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabbarVC.selected(0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//                    let webViewBottomSheep = WebViewBottomSheet()
//                    webViewBottomSheep.urlString = urlStr
//                    webViewBottomSheep.start(viewController: betleadMain)
                })
            }
        }
    }
    func setMemberViewControllerDefault() {
        tabbarVC.memberVC.setDefault()
    }
    func getTabbarVC() -> TabbarViewController? {
        return UIApplication.topViewController() as? TabbarViewController
    }
}
