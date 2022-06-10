//
//  AppDelegate.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import UIKit
import Toaster
import RxSwift
import DropDown
public typealias CheckCompletionBlock = (Bool) -> Void
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var isLogin:Bool?
    {
        didSet{
            //走正常流程時,判斷是否已登入過
            if isLogin == true
            {
                let walletNavVC = MDNavigationController(rootViewController: WalletViewController.loadNib())
                window?.rootViewController = walletNavVC
            }else
            {
                DeepLinkManager.share.handleDeeplink(navigation: .login)
            }
        }
    }
    var domainMode : DomainMode = .Dev{
        didSet{
            BuildConfig().domainSet(mode: domainMode)
        }
    }
    var timer: Timer?
    private let dpg = DisposeBag()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        setupAppearance()
        initSingleton()
        launchFromNotification(options: launchOptions)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let vc = LaunchReciprocalViewController.loadNib()
        window?.rootViewController = vc
        return true
    }
    private func setupAppearance(){
        
        KeychainManager.share.clearToken()
    }
    private func initSingleton(){
        Toast.bindSubject()
        ToastView.appearance().bottomOffsetPortrait = 200
#if Mundo_PRO || Approval_PRO
        self.domainMode = .Pro
#else
        self.domainMode = KeychainManager.share.getDomainMode()
        Toast.show(msg: "目前是 \(self.domainMode.rawValue) 環境\n 域名:\(BuildConfig.Domain)")
#endif

    }
    func launchFromNotification(options: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let deeplinkName = (options?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any])?["deeplink"] as? String else { return }
        DeepLinkManager.share.navigation = DeepLinkManager.Navigation(typeName: deeplinkName)
        DeepLinkManager.share.handleDeeplink(navigation: DeepLinkManager.share.navigation)
        DropDown.startListeningToKeyboard()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        application.beginBackgroundTask {} // allows to run background tasks
        // 消除倒數
        stopRETimer()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 檢查版本
        checkAppVersion()
        
        if let vc = UIApplication.topViewController() {
            print("current top vc: \(vc)")
            if vc.isKind(of: LaunchReciprocalViewController.self) { return }
            if vc.isKind(of: LoginSignupViewController.self) { return }
            if let vcArray = vc.navigationController?.viewControllers
            {
                for vc in vcArray {
                    if vc is LoginSignupViewController
                    {
                        return
                    }
                }
            }
            if !vc.isKind(of: TabbarViewController.self) {
                // 檢查時間
                checkTime()
            } else {
                print("current vc is tabbar vc finished.")
                
            }
        }
    }
    
    func checkAppVersion() {
      
    }
    
    func checkTime(complete:CheckCompletionBlock? = nil)
    {
        // 打API 檢查是否過期
        checkAPIToken(complete: complete)
    }
    func checkAPIToken(complete:CheckCompletionBlock? = nil)
    {
        // ErrorHandler 已經有過期導去登入
        LoadingViewController.show()
        Beans.walletServer.walletBalances().subscribe { [self](dto) in
            _ = LoadingViewController.dismiss()
            // 沒過期,打refresh API, 時間加30分鐘
            SocketIOManager.sharedInstance.establishConnection()
            Log.v("沒過期")
            if let successBlock = complete
            {
                successBlock(true)
            }else
            {
                freshToken()
            }
        } onError: { (error) in
            _ = LoadingViewController.dismiss()
            if let successBlock = complete
            {
                successBlock(false)
            }else
            {
                DeepLinkManager.share.handleDeeplink(navigation: .login)                
            }
            //過期去登入頁面
        }.disposed(by: dpg)
    }
    func freshToken()
    {
        Log.v("刷新Token")
        Beans.loginServer.refreshToken().subscribeSuccess { [self]dto in
            if let dataDto = dto
            {
                KeychainManager.share.setToken(dataDto.token)
                // 刷新時間
                startToCountDown()
            }
        }.disposed(by: dpg)
    }
    func startToCountDown() {
        Log.v("刷新時間")
        stopRETimer()
        var countInt = 1500
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            countInt -= 1
            DispatchQueue.main.async {
                // 先關起來
//                Log.e("剩餘時間 : \(countInt) 秒")
                if countInt == 0 {
                    timer.invalidate()
                    strongSelf.freshToken()
                }
            }
        }
        timer?.fire()
    }
    func stopRETimer()
    {
        Log.v("消除倒數timer")
        SocketIOManager.sharedInstance.closeConnection()
        timer?.invalidate()
        timer = nil
    }
}

