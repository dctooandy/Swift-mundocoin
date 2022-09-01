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
    private var waitForGotoWallet = false
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
    // MARK: -
    // MARK:業務方法
    func startToCountDown() {
        checkForDirectAndWait()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            strongSelf.count -= 1
            DispatchQueue.main.async {
                print("倒數： \(strongSelf.count)")
//                strongSelf.reciprocalLabel.text = "\(strongSelf.count) 秒"
                if strongSelf.count == 0 {
                    timer.invalidate()
                    if strongSelf.firstStart == false
                    {
                        strongSelf.checkForDirectAndWait(immediately: true)
                    }else
                    {
                        if strongSelf.waitForGotoWallet == true
                        {
                            #if Approval_PRO || Approval_DEV || Approval_STAGE
                            strongSelf.goToAuditMainVC()
                            #else
                            strongSelf.goToWallet()
                            #endif
                        }else
                        {
                            strongSelf.goToLogin()
                        }
                    }
                }
            }
        }
    }
    
    func checkForDirectAndWait(immediately:Bool = false) {
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
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
                        appdelegate.checkTime(complete: { [self] flag in
                            firstStart = true
                            waitForGotoWallet = flag
                            if immediately == true
                            {
                                if waitForGotoWallet == true
                                {
                                    #if Approval_PRO || Approval_DEV || Approval_STAGE
                                    goToAuditMainVC()
                                    #else
                                    goToWallet()
                                    #endif
                                }else
                                {
                                    goToLogin()
                                }
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
    func goToWallet()
    {
        // socket
        SocketIOManager.sharedInstance.establishConnection()
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
    
    func isLaunchBefore() -> Bool {
        let isLaunchBefore = UserDefaults.Verification.bool(forKey: .launchBefore)
        if !isLaunchBefore {
            UserDefaults.Verification.set(value: true, forKey: .launchBefore)
        }
        return isLaunchBefore
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


