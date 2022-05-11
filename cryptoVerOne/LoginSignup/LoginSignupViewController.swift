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
enum ShowMode {
    case login
    case signup
    case forgotPW
}
class LoginSignupViewController: BaseViewController {
    // MARK:業務設定
    fileprivate let loginPageVC = LoginPageViewController()
    static let share: LoginSignupViewController = LoginSignupViewController.loadNib()
    /// 显示注册或登入页面
    private var currentShowMode: ShowMode = .login {
        didSet {
            resetUI()
            loginPageVC.reloadPageMenu(currentMode: currentShowMode)
        }
    }
//    private var isLogin: Bool = true {
//        didSet {
//            resetUI()
//            loginPageVC.reloadPageMenu(isLogin: isLogin)
//        }
//    }
    private var shouldVerify = false
    private var route: SuccessViewAction.Route? = nil
    private var backGroundVideoUrl: URL? = nil
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImv: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    private lazy var switchButton:UIButton = {
        let rightBtn = UIButton()
        rightBtn.setTitle("Sign Up".localized, for:.normal)
        rightBtn.setTitleColor(.black, for: .normal)
        rightBtn.titleLabel?.font = Fonts.pingFangSCRegular(20)
        rightBtn.addTarget(self, action: #selector(switchViewAction), for: .touchUpInside)
        return rightBtn
    }()
    private lazy var backToButton:UIButton = {
        let backToButton = UIButton()
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: Views.backImageHeight(), height: Views.backImageHeight())).withRenderingMode(.alwaysTemplate)
        backToButton.setImage(image, for: .normal)
        backToButton.tintColor = .black
        backToButton.addTarget(self, action:#selector(backToLoginView), for:.touchUpInside)
        return backToButton
    }()
    private var successView: SignupSuccessView?
    private let tabbarVC = TabbarViewController()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginPageVC()
        bindLoginPageVC()
//        updateBottomView()
        setupUI()
        binding()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addDateSelectedButton()
        currentShowMode = .login
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:switchBtn)
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bioVerifyCheck()
//        VideoManager.share.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        VideoManager.share.pause()
    }
    // MARK: -
    // MARK:業務方法
    private func addDateSelectedButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: switchButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backToButton)
        backToButton.isHidden = true
    }
    @objc func switchViewAction() {
        self.changeLoginState()
    }
    @objc func backToLoginView(isAnimation : Bool = true)
    {
        currentShowMode = .login
    }
    private func bioVerifyCheck(isDev : Bool = false) {
        if isDev
        {
            // 進行臉部或指紋驗證
            BioVerifyManager.share.bioVerify { [weak self] (success, error) in
                if !success {
                    Toast.show(msg: "验证失败，请输入帐号密码")
                    return
                }
                if error != nil {
                    Toast.show(msg: "验证失败：\(error!.localizedDescription)")
                    return
                }
//                self?.login(dto: loginPostDto)
//                self?.loginPageVC.setAccount(acc: loginPostDto.account, pwd: loginPostDto.password)
            }
        }else
        {
//            if !isLogin { return }
            if currentShowMode != .login { return }
            if !BioVerifyManager.share.bioLoginSwitchState() { return }            
            if let loginPostDto = KeychainManager.share.getLastAccount(),
               BioVerifyManager.share.usedBIOVeritfy(loginPostDto.account) {
                // 進行臉部或指紋驗證
                BioVerifyManager.share.bioVerify { [weak self] (success, error) in
                    if !success {
                        Toast.show(msg: "验证失败，请输入帐号密码")
                        return
                    }
                    if error != nil {
                        Toast.show(msg: "验证失败：\(error!.localizedDescription)")
                        return
                    }
                    self?.login(dto: loginPostDto)
                    self?.loginPageVC.setAccount(acc: loginPostDto.account, pwd: loginPostDto.password)
                }
            } else {
                print("manual login.")
            }
        }
    }
 
//    func isLogin(_ isLogin: Bool) -> LoginSignupViewController {
//        self.isLogin = isLogin
//        return self
//    }
    func showMode(_ showMode: ShowMode) -> LoginSignupViewController {
        self.currentShowMode = showMode
        return self
    }
    
    // MARK: - Actions
    func setMemberViewControllerDefault() {
        tabbarVC.memberVC.setDefault()
    }
    
    private func binding() {
        logoImv.rx.click
            .subscribeSuccess { [weak self] in
//                self?.bioVerifyCheck(isDev: true)
                self?.goWalletViewController()
            }.disposed(by: disposeBag)
        
//        switchButton.rx.tap
//            .subscribeSuccess { [weak self] in
////                DispatchQueue.main.async {
////                    self?.changeLoginState()
////                }
//            }.disposed(by: disposeBag)
    }
    func getTabbarVC() -> TabbarViewController? {
        return UIApplication.topViewController() as? TabbarViewController
    }
    func bindLoginPageVC() {
        // 登入
        loginPageVC.rxLoginBtnClick().subscribeSuccess { [weak self] (dto) in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
            if strongSelf.shouldVerify {
                strongSelf.showImageVerifyView(dto)
                return
            }
            // 發送驗證碼
            self?.sendVerifyCodeForEmailLogin(dto)
            // 推向传送验证码VC
            let verifyVC = VerifyViewController.loadNib()
            verifyVC.loginDto = dto
            self?.navigationController?.pushViewController(verifyVC, animated: true)
        }.disposed(by: disposeBag)
        
        // 註冊
        loginPageVC.rxSignupBtnClick().subscribeSuccess { [weak self] (dto) in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
            if strongSelf.shouldVerify {
                strongSelf.showImageVerifyView(dto)
                return
            }
            // 發送驗證碼
            self?.sendVerifyCodeForEmailSignup(dto)
            // 推向传送验证码VC
            let verifyVC = VerifyViewController.loadNib()
            verifyVC.signupDto = dto
            self?.navigationController?.pushViewController(verifyVC, animated: true)
//            strongSelf.signup(dto: dto)
        }.disposed(by: disposeBag)
        
        // 發送驗證碼
        loginPageVC.rxVerifyCodeBtnClick().subscribeSuccess { [weak self] (phone) in
            self?.view.endEditing(true)
            self?.sendVerifyCodeForPhone(phone)
        }.disposed(by: disposeBag)
        
        // 發送reset 密碼
        loginPageVC.rxResetPWBtnClick().subscribeSuccess { [weak self] (dto) in
            self?.view.endEditing(true)
            self?.sendResetLinkForEmail(dto)
        }.disposed(by: disposeBag)
        
        // 忘記密碼
        loginPageVC.rxForgetBtnClick().subscribeSuccess { [weak self] in
            self?.view.endEditing(true)
            self?.showForgetPasswordVC()
        }.disposed(by: disposeBag)
    }
    // MARK: 驗證碼
    private func sendVerifyCodeForEmailLogin(_ loginDto: LoginPostDto) {
        // 傳送驗證碼供Email登入
        Log.i("傳送驗證碼供Email登入使用")
    }
    private func sendVerifyCodeForEmailSignup(_ loginDto: SignupPostDto) {
        // 傳送驗證碼供Email登入
        Log.i("傳送驗證碼供Email註冊使用")
    }
    // MARK: 驗證碼
    private func sendEmailVerifyCodeForForgot(_ dto: LoginPostDto) {
        // 傳送驗證碼
        Log.i("傳送Email驗證碼供忘記密碼使用")
    }
    private func sendVerifyCodeForPhone(_ phone: String) {
        Log.i("傳送驗證碼供Phone使用")
//        Beans.memberServer
//            .sendVerifyCode(phone, isLogin: isLogin)
//            .subscribeSuccess({ [weak self] (res) in
//                guard let strongSelf = self else { return }
//                if res.1 != 1 { return }
//                print("otp: \(res.0.otp ?? "no otp")")
//                DispatchQueue.main.async {
//                    strongSelf.loginPageVC.startReciprocal()
//                }
//                #if DEBUG // 測試時直接把otp貼在textfield上
//                DispatchQueue.main.async {
//                    strongSelf.loginPageVC.setVerifyCode(code: res.0.otp ?? "")
//                }
//                #endif
//            }).disposed(by: disposeBag)
    }
    // MARK: 重設密碼
    private func sendResetLinkForEmail(_ dto: LoginPostDto) {
        Log.e("重設密碼")
        // 發送驗證碼
        self.sendEmailVerifyCodeForForgot(dto)
        // 推向传送验证码VC
        let verifyVC = VerifyViewController.loadNib()
        verifyVC.loginDto = dto
        self.navigationController?.pushViewController(verifyVC, animated: true)
    }
    // MARK: 忘記密碼
    private func showForgetPasswordVC() {
        Log.e("忘記密碼")
//        self.present(ForgetPasswordViewController(), animated: true, completion: nil)
        currentShowMode = .forgotPW
    }
    
    // Confirm Touch/Face ID
    private func showBioConfirmView() {
        let popVC =  ConfirmPopupView(title: "登入确认",
                                      message: "启用脸部辨识或指纹辨识进行登入？") { [weak self] isOK in
                                        if isOK {
                                            guard let acc = MemberAccount.share?.account else { return }
                                            BioVerifyManager.share.applyMemberInBIOList(acc)
                                        }
                                        BioVerifyManager.share.setBioLoginSwitch(to: isOK)
                                        self?.navigateToRouter(showBioView: false)
        }
        DispatchQueue.main.async {[weak self] in
            self?.present(popVC, animated: true, completion: nil)
        }
    }
    
    func login(dto: LoginPostDto, checkBioList: Bool = true , route: SuccessViewAction.Route = .main, showLoadingView: Bool = true) {
        LoadingViewController.show()
//        Beans.memberServer
//            .login(dto: dto)
//            .subscribe(onSuccess: { [weak self] (res) in
//                guard let strongSelf = self else { return }
//                //_ = MemberDto.update()
//                strongSelf.removeSuccessView()
//                strongSelf.shouldVerify = false
//                strongSelf.postPushDevice()
//                MemberAccount.share = MemberAccount(account: dto.account,
//                                                    password: dto.password,
//                                                    loginMode: dto.loginMode)
//                KeychainManager.share.setLastAccount(dto.account)
//                if dto.loginMode == .account {
//                    BioVerifyManager.share.applyMemberInBIOList(dto.account)
//                    KeychainManager.share.updateAccount(acc: dto.account,
//                                                        pwd: dto.password)
//                }
                let didAskBioLogin = BioVerifyManager.share.didAskBioLogin()
                let showBioView = (dto.loginMode == .account) && checkBioList && !didAskBioLogin
//                strongSelf.setLoginPageToDefault()
                self.handleLoginSuccess(showLoadingView: showLoadingView,
                                              showBioView: showBioView,
                                              route: route)
//                }, onError: { [weak self] (error) in
//                    self?.handleApiServiceError(error)
//            }).disposed(by: disposeBag)
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
                BioVerifyManager.share.applyLogedinAccount(MemberAccount.share!.account)
                BioVerifyManager.share.setBioLoginAskStateToTrue()
            }
        } else {
            if DeepLinkManager.share.navigation != .none {
                goMainViewController()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    DeepLinkManager.share.navigation.toTargetVC()
                    DeepLinkManager.share.navigation = .none
                }
                return
            }
            
            switch route {
            case .main: goMainViewController()
            case .personal: goPersonalViewController()
            case .bet: goBetViewController()
            case .clickAD(let url): goADPopupView(urlStr: url)
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
    
    // MARK: 註冊
    func signup(dto: SignupPostDto) {
        LoadingViewController.show()
//        Beans.memberServer
//            .signup(dto: dto)
//            .subscribe(onSuccess: { [weak self] (res) in
//                self?.signupSuccess(dto: dto, res: res)
//            }, onError: { [weak self] (error) in
//                self?.handleApiServiceError(error)
//            }).disposed(by: disposeBag)
        let res = SignupDto(account: dto.account, password: dto.password)
        self.signupSuccess(dto: dto, res: (res,1))
    }
    
    func signupSuccess(dto: SignupPostDto, res: (SignupDto?, Int)) {
        LoadingViewController.action(mode: .success, title: "注册成功")
            .subscribeSuccess({ [weak self]_ in
                self?.shouldVerify = false
                DispatchQueue.main.async {
                    if dto.signupMode == .phone {
                        guard let acc = res.0?.account, let pwd = res.0?.password else { return }
                        KeychainManager.share.saveAccPwd(acc: acc,
                                                         pwd: pwd,
                                                         tel: dto.account)
                        
                        self?.showSignupSuccessView(acc: acc,
                                                    pwd: pwd,
                                                    mode: dto.signupMode)
                        return
                    }
                    KeychainManager.share.saveAccPwd(acc: dto.account,
                                                     pwd: dto.password,
                                                     tel: "")
                    self?.showSignupSuccessView(acc: dto.account,
                                                pwd: dto.password,
                                                mode: dto.signupMode)
                }
            }).disposed(by: disposeBag)
    }
    
    func handleApiServiceError(_ error: Error) {
        guard let err = error as? ApiServiceError else { return }
        ErrorHandler.show(error: err)
        if err == .failThrice {
            shouldVerify = true
        }
    }
    // MARK: Login Video
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
    private func fetchLoginVideofromLocal() {
        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeUrl = baseUrl.appendingPathComponent("loginVideo.mp4")
        if FileManager.default.fileExists(atPath: storeUrl.path) {
            backGroundVideoUrl = storeUrl
        } else {
            backGroundVideoUrl = URL(string: BuildConfig.LOGIN_VIDEO_URL)
        }
    }
    
    // MARK: - ViewController navigation
    func changeLoginState() {// 登入註冊頁面
//        isLogin = !isLogin
        currentShowMode = ((currentShowMode == .login) ? .signup : .login)
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
    
    func goBetViewController() {
//        tabbarVC.mainPageVC.shouldFetchGameType = true
        let betleadMain = BetleadNavigationController(rootViewController:tabbarVC)
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            print("go bet")
            mainWindow.rootViewController = betleadMain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tabbarVC.selected(3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//                    UIApplication.topViewController()?.navigationController?.pushViewController(BetRecordViewController(), animated: true)
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
    func goWalletViewController() {
//        tabbarVC.selected(0)
        let walletVC = WalletViewController.loadNib()
        let walletNavVC = MDNavigationController(rootViewController: walletVC)
        
//        let betleadMain = BetleadNavigationController(rootViewController: tabbarVC)
        DispatchQueue.main.async {
            if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
                print("go wallet")
                mainWindow.rootViewController = walletNavVC
                mainWindow.makeKeyAndVisible()
            }
        }
    }
    //MARK: - 註冊成功頁面
    func showSignupSuccessView(acc: String, pwd: String, mode: LoginMode) {
        shouldVerify = false
        successView = SignupSuccessView.loadNib()
        successView?.account = acc
        successView?.password = pwd
        successView?.setup(title: mode.signupSuccessTitles().title,
                          buttonTitle: mode.signupSuccessTitles().doneButtonTitle,
                          showAccount: mode.signupSuccessTitles().showAccount)
        view.addSubview(successView!)
        successView?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        bindSignupSuccessView()
    }
    
    func bindSignupSuccessView() {
        successView?.rxSuccessViewDidPressed()
            .subscribeSuccess { [weak self] (type) in
                switch type {
                case .toMainView(let acc, let pwd):
                    
                    let dto = LoginPostDto(account: acc,
                                           password: pwd,
                                           loginMode: .account,
                                           showMode: self!.currentShowMode)
                    self?.login(dto: dto, checkBioList: false, showLoadingView: false)
                case .toPersonal(let acc, let pwd):
                    
                    let dto = LoginPostDto(account: acc,
                                           password: pwd,
                                           loginMode: .account,
                                           showMode: self!.currentShowMode)
                    self?.login(dto: dto, checkBioList: false , route: type.route, showLoadingView: false)
                case .toBet(let acc, let pwd):
                    let dto = LoginPostDto(account: acc,
                                           password: pwd,
                                           loginMode: .account,
                                           showMode: self!.currentShowMode)
                    self?.login(dto: dto, checkBioList: false , route: type.route, showLoadingView: false)
                case .clickAD(let acc, let pwd, _):
                    let dto = LoginPostDto(account: acc,
                                           password: pwd,
                                           loginMode: .account,
                                           showMode: self!.currentShowMode)
                    self?.login(dto: dto, checkBioList: false , route: type.route, showLoadingView: false)
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    func removeSuccessView() {
        successView?.removeFromSuperview()
        successView = nil
    }
    
    //MARK: - 顯示滑塊驗證
    private func showImageVerifyView(_ postDto: Any) {
        let imageVerifyView = ImageVerifyView()
        self.view.addSubview(imageVerifyView)
        imageVerifyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        imageVerifyView
            .rxVerifySuccess()
            .subscribeSuccess { [weak self] (success) in
                if let dto = postDto as? SignupPostDto {
                    self?.signup(dto: dto)
                } else if let dto = postDto as? LoginPostDto {
                    self?.login(dto: dto, checkBioList: dto.loginMode == .account)
                }
                imageVerifyView.removeFromSuperview()
            }.disposed(by: disposeBag)
        
    }
}

// MARK: -
// MARK: 延伸
extension LoginSignupViewController {
    
    private func setupUI() {
        
//        dismissButton.snp.makeConstraints { (make) in
//            make.size.equalTo(height(24/812))
//            make.top.equalToSuperview().offset(topOffset(56/812))
//            make.left.equalToSuperview().offset(leftRightOffset(24/375))
//        }
        
//        backgroundImageView.snp.makeConstraints { (make) in
//            make.top.left.right.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.26)
//        }
        resetUI()
//        backgroundImageView.image = #imageLiteral(resourceName: "Member-Bg-purple")
    }
    
    private func resetUI() {
//        updateBottomView()
        switch currentShowMode {
        case .login:
            fetchBackgroundVideo()
            backgroundImageView.isHidden = false
            switchButton.setTitle("Sign Up".localized, for: .normal)
            topLabel.text = "Log In to Mundocoin".localized
            logoImv.isHidden = false
            switchButton.isHidden = false
            backToButton.isHidden = true
        case .signup:
            backgroundImageView.isHidden = false
            switchButton.setTitle("Log In".localized, for: .normal)
            topLabel.text = "Create Your Account".localized
            logoImv.isHidden = true
            switchButton.isHidden = false
            backToButton.isHidden = true
        case .forgotPW:
            backgroundImageView.isHidden = false
            switchButton.setTitle("".localized, for: .normal)
            topLabel.text = "Forgot password".localized
            logoImv.isHidden = true
            switchButton.isHidden = true
            backToButton.isHidden = false
        }
//        if isLogin {
//            fetchBackgroundVideo()
//            backgroundImageView.isHidden = false
////            bottomLabel.text = "还没有倍利帐号？"
////            bottomLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//            switchButton.setTitle("Sign Up".localized, for: .normal)
//            topLabel.text = "Log In to Mundocoin".localized
//            logoImv.isHidden = false
//        } else {
//            backgroundImageView.isHidden = false
////            VideoManager.share.removeVideoLayer()
////            bottomLabel.text = "已经有倍利帐号？"
////            bottomLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//            switchButton.setTitle("Log In".localized, for: .normal)
//            topLabel.text = "Create Your Account".localized
//            logoImv.isHidden = true
//        }
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
    
    private func setupLoginPageVC() {
        addChild(loginPageVC)
        view.insertSubview(loginPageVC.view, aboveSubview: backgroundImageView)
        loginPageVC.view.snp.makeConstraints({ (make) in
            make.top.equalTo(self.topLabel.snp.bottom).offset(30)
//            make.top.equalToSuperview().offset(topOffset(136/812))
            make.left.bottom.right.equalToSuperview()
        })
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
}
extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 51)
    }
}
