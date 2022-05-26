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
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var isLogin:Bool?
    {
        didSet{
            //走正常流程時,判斷是否已登入過
            let loginNavVC = MuLoginNavigationController(rootViewController: LoginSignupViewController.share)
            let walletNavVC = MDNavigationController(rootViewController: WalletViewController.loadNib())
            window?.rootViewController = isLogin! ? walletNavVC : loginNavVC
        }
    }
    var timer: Timer?
    private let dpg = DisposeBag()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()
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
    }
    func launchFromNotification(options: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let deeplinkName = (options?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any])?["deeplink"] as? String else { return }
        DeepLinkManager.share.navigation = DeepLinkManager.Navigation(typeName: deeplinkName)
        DeepLinkManager.share.handleDeeplink(navigation: DeepLinkManager.share.navigation)
        DropDown.startListeningToKeyboard()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // 消除倒數
        stopRETimer()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 檢查版本
        checkAppVersion()
        // 檢查時間
        checkTime()
    }
    
    func checkAppVersion() {
      
    }
    
    func checkTime()
    {
        // 打API 檢查是否過期
        checkAPIToken()
    }
    func checkAPIToken()
    {
        // ErrorHandler 已經有過期導去登入
        Beans.walletServer.walletAddress().subscribe { [self](dto) in
            // 沒過期,打refresh API, 時間加30分鐘
            Log.e("沒過期")
            freshToken()
            startToCountDown()
        } onError: { [self](error) in
            //先啟動
            Log.e("沒過期")
            freshToken()
            startToCountDown()
            //過期去登入頁面
//            DeepLinkManager.share.handleDeeplink(navigation: .login)
        }.disposed(by: dpg)
    }
    func freshToken()
    {
        Log.e("刷新Token")
        // 等API
        // 刷新時間
        startToCountDown()
    }
    func startToCountDown() {
        Log.e("刷新時間")
        stopRETimer()
        var countInt = 1500
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            countInt -= 1
            DispatchQueue.main.async {
                Log.e("剩餘時間 : \(countInt) 秒")

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
        Log.e("消除倒數timer")
        timer?.invalidate()
        timer = nil
    }
}

