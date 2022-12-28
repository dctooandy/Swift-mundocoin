//
//  LaunchReciprocalViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import UIKit
import RxCocoa
import RxSwift

class LaunchReciprocalViewController: BaseViewController {
    // MARK:業務設定
    private var count = 1
    private var firstStart = false
    var sectionflag:SectionExpired = .forceLogout
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var backGroundImageView: UIImageView!
    let loginVC =  LoginSignupViewController.share
    let auditLoginVC =  AuditLoginViewController.loadNib()
    @IBOutlet weak var reciprocalLabel: UILabel!
    @IBOutlet weak var beleadLeftIcon:UIImageView!
    @IBOutlet weak var beleadRightTopIcon:UIImageView!
    @IBOutlet weak var beleadRightBottomLabel:UILabel!
    @IBOutlet weak var copyrightLabel:UILabel!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkVersion()
        beleadLeftIcon.transform = CGAffineTransform(translationX: 0, y: 50)
        beleadRightTopIcon.transform = CGAffineTransform(translationX: -30, y: 0)
        beleadRightBottomLabel.transform = CGAffineTransform(translationX: -30, y: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startToCountDown()
        startAnimation()
    }
    static func instance(sectionflag : SectionExpired ) -> LaunchReciprocalViewController {
        let vc = LaunchReciprocalViewController.loadNib()
        vc.sectionflag = sectionflag
        return vc
    }
    // MARK: -
    // MARK:業務方法
    func startToCountDown() {
        checkForDirectAndWait()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] (timer) in
            count -= 1
            DispatchQueue.main.async { [self] in
                print("倒數： \(count)")
//                strongSelf.reciprocalLabel.text = "\(strongSelf.count) 秒"
                if count == 0 {
                    timer.invalidate()
                    if firstStart == false
                    {
                        checkForDirectAndWait(immediately: true)
                    }else
                    {
                        subClassForSectionExpired(sectionflag: sectionflag)
                    }
                }
            }
        }
    }
    
    func checkForDirectAndWait(immediately:Bool = false) {
        if let _ = (UIApplication.shared.delegate as? AppDelegate)?.window {
            if showUpdateAlert {
                appUpdateAlert()
                return
            }
            if firstStart == false
            {
                if UserStatus.share.isLogin == true
                {
                    // 自動登入
                    // 檢查token動作
                    if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                        appdelegate.checkTime(complete: { [self] sectionResult in
                            firstStart = true
                            sectionflag = sectionResult
                            if immediately == true
                            {
                                subClassForSectionExpired(sectionflag: sectionflag)
                            }
                        })
                    }
                }
                else
                {
                    firstStart = true
                    if immediately == true
                    {
                        goToLogin()
                    }
                }
            }
        }
    }
    func subClassForSectionExpired(sectionflag:SectionExpired)
    {
        if sectionflag == .inSection
        {
            #if Approval_PRO || Approval_DEV || Approval_STAGE
            goToAuditMainVC()
            #else
            goToWallet()
            #endif
        }else if sectionflag == .forceLogout
        {
            goToLogin()
        }else
        {
            // 淺登出
            goToLightLogoutAction()
        }
    }
    func goToLightLogoutAction()
    {
        if BioVerifyManager.share.bioLoginSwitchState() == true ,
            let loginPostDto = KeychainManager.share.getLastAccountDto(),
           (BioVerifyManager.share.usedBIOVeritfy(loginPostDto.account) ||
            BioVerifyManager.share.usedBIOVeritfy(loginPostDto.phone))
        {
            Log.i("使用FaceID")
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
            {
                let vc = LoginQuicklyViewController.loadNib()
                let quicklyNavVC = MDNavigationController(rootViewController: vc)
                mainWindow.rootViewController = quicklyNavVC
                mainWindow.makeKeyAndVisible()
            }
        }else
        {
            Log.i("不使用FaceID")
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
            {
                let vc = LoginQuicklyPasswordViewController.instance(faceIDPrefixVC: false)
                let quicklyNavVC = MDNavigationController(rootViewController: vc)
                mainWindow.rootViewController = quicklyNavVC
                mainWindow.makeKeyAndVisible()
            }
        }
    }
    func fetchAddressBookList()
    {
        Log.i("更新地址簿")
        _ = AddressBookListDto.update(done: {})
    }
    func goToWallet()
    {
        // socket
        SocketIOManager.sharedInstance.establishConnection()
        // addfressBook
        fetchAddressBookList()
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
        {
            let walletVC = WalletViewController.loadNib()
            let walletNavVC = MDNavigationController(rootViewController: walletVC)
            appDelegate.freshToken()
            mainWindow.rootViewController = walletNavVC
            mainWindow.makeKeyAndVisible()
        }
    }
    func goToAuditMainVC()
    {
        // socket
        SocketIOManager.sharedInstance.establishConnection()
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
        {
            DispatchQueue.main.async {
                appDelegate.freshToken()
                mainWindow.rootViewController = AuditTabbarViewController()
                mainWindow.makeKeyAndVisible()
            }
        }
    }
    func goToLogin()
    {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
        {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            let auditNavVC = MDNavigationController(rootViewController: auditLoginVC)
            mainWindow.rootViewController = auditNavVC
#else
            let loginNavVC = MuLoginNavigationController(rootViewController: loginVC)
            mainWindow.rootViewController = loginNavVC
#endif
            mainWindow.makeKeyAndVisible()
        }
    }
    private func appUpdateAlert() {
        AppUpdateAlert(AppVersionDto.share) { [weak self](success) in
            if AppVersionDto.share != nil && AppVersionDto.share!.appVersionForceUpdate!.value! {
                return
            }
            self?.showUpdateAlert = false
            self?.checkForDirectAndWait(immediately: true)            
        }.start(viewController: self)
    }
    
    private func startAnimation(){
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
            self.beleadLeftIcon.alpha = 1
            self.beleadLeftIcon.transform = CGAffineTransform.identity
            self.beleadRightTopIcon.alpha = 1
            self.beleadRightTopIcon.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.75, delay: 0.3, options: .curveEaseInOut, animations: {
            self.beleadRightBottomLabel.alpha = 1
            self.beleadRightBottomLabel.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }

    private var showUpdateAlert = false
    func checkVersion() {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        backGroundImageView.image = UIImage(named: "Audit_Launcher")
        
        beleadRightBottomLabel.text = "Approval"
#else
        backGroundImageView.image = UIImage(named: "App_Launcher")
        beleadRightBottomLabel.text = "MundoCoin"
#endif
        // TODO: API
//        Beans.baseServer.appVersion()
//            .subscribeSuccess { [weak self] (dto) in
//                AppVersionDto.didFetch = true
//                AppVersionDto.share = dto
//                self?.showUpdateAlert = dto != nil
//            }.disposed(by: disposeBag)
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


