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
import JWTDecode
import Firebase
import BackgroundTasks

public typealias CheckCompletionBlock = (Bool) -> Void
let backgroundAppRefreshTaskSchedulerIdentifier = "com.example.fooBackgroundAppRefreshIdentifier"
let backgroundProcessingTaskSchedulerIdentifier = "com.example.fooBackgroundProcessingIdentifier"
//@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK:業務設定
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var timer: Timer?
    var bgTimer: Timer?
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
    var domainMode : DomainMode = .Stage{
        didSet{
            BuildConfig().domainSet(mode: domainMode)
        }
    }
//    var timer: Timer?
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:Life cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        setupAppearance()
        registerBackgroundTasks()
        if detectIsJialbrokenDevice()
        {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            let vc = UIViewController()
            window?.rootViewController = vc
            self.showAlertForJillbreakDevice(withVC: vc)
        }else
        {
            initSingleton()
            launchFromNotification(options: launchOptions)
            askForLocalNotification(application: application)
            application.applicationIconBadgeNumber = 0
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            let vc = LaunchReciprocalViewController.loadNib()
            window?.rootViewController = vc
        }
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map{ String(format: "%02.2hhx", $0) }.joined()
        Log.v("Token : \(token)")
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.v("遠端推播註冊失敗 \(error)")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        //虽然定义了后台获取的最短时间，但iOS会自行以它认定的最佳时间来唤醒程序，这个我们无法控制
        //UIApplicationBackgroundFetchIntervalMinimum 尽可能频繁的调用我们的Fetch方法
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        application.beginBackgroundTask {
            Log.i("背景執行 開始")
//            self.backgroundTaskTenMins()
        } // allows to run background tasks
        self.submitBackgroundTasks()
        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block:
//                                        {
//            (timer) in
//
//            Log.i("背景執行 計時倒數: \(UIApplication.shared.backgroundTimeRemaining)")
//        })
        // 消除倒數
        CheckTokenService.share.stopRETimer()
//        stopRETimer()
//        SocketIOManager.sharedInstance.closeConnection()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTasksWillEnterForeground(application)
        if detectIsJialbrokenDevice()
        {
            if let vc = window?.rootViewController
            {
                self.showAlertForJillbreakDevice(withVC: vc)
            }
        }else
        {
            // 檢查版本
            checkAppVersion()
            
            if let vc = UIApplication.topViewController() {
                print("current top vc: \(vc)")
                if vc.isKind(of: LaunchReciprocalViewController.self) { return }
#if Approval_PRO || Approval_DEV || Approval_STAGE
                if vc.isKind(of: AuditLoginViewController.self) { return }
#else
                if vc.isKind(of: LoginSignupViewController.self) { return }
#endif
                if let vcArray = vc.navigationController?.viewControllers
                {
                    for vc in vcArray {
#if Approval_PRO || Approval_DEV || Approval_STAGE
                        if vc is AuditLoginViewController { return }
#else
                        if vc is LoginSignupViewController { return }
#endif
                    }
                }
                // 檢查時間
                checkTime()
//                if !vc.isKind(of: TabbarViewController.self) ,
//                   !vc.isKind(of: AuditTabbarViewController.self){
//                } else {
//                    print("current vc is tabbar vc finished.")
//                }
                
            }
        }
    }
    // MARK: -
    // MARK:業務方法
    func launchFromNotification(options: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let deeplinkName = (options?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any])?["deeplink"] as? String else { return }
        DeepLinkManager.share.navigation = DeepLinkManager.Navigation(typeName: deeplinkName)
        DeepLinkManager.share.handleDeeplink(navigation: DeepLinkManager.share.navigation)
    }
    func askForLocalNotification(application: UIApplication)
    {
        // 在程式一啟動即詢問使用者是否接受圖文(alert)、聲音(sound)、數字(badge)三種類型的通知
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge, .carPlay], completionHandler: { (granted, error) in
            if granted {
                Log.v("使用者 允許 接收通知")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                Log.e("使用者 不允許 接收通知")
            }
        })
        // 代理 UNUserNotificationCenterDelegate，這麼做可讓 App 在前景狀態下收到通知
        UNUserNotificationCenter.current().delegate = self
    }
    private func setupAppearance(){
        
        KeychainManager.share.clearToken()
    }
    private func initSingleton(){
        // 1025 FaceID 功能狀態
        _ = KeychainManager.share.setFaceIDStatus(true)
        // 0920 註冊取消驗證碼輸入
        _ = KeychainManager.share.setRegistrationMode(false)
        // 1006 白名單功能開關
        _ = KeychainManager.share.setWhiteListModeEnable(true)
        Toast.bindSubject()
        ToastView.appearance().bottomOffsetPortrait = 200
        if isLaunchBefore() == false {
#if Mundo_PRO
            _ = KeychainManager.share.setDomainMode(.Pro)
#elseif Mundo_STAGE
            _ = KeychainManager.share.setDomainMode(.Stage)
#elseif Mundo_DEV
            _ = KeychainManager.share.setDomainMode(.Dev)
#elseif Mundo_QA
            _ = KeychainManager.share.setDomainMode(.Qa)
#elseif Approval_PRO
            _ = KeychainManager.share.setDomainMode(.AuditPro)
#elseif Approval_STAGE
            _ = KeychainManager.share.setDomainMode(.AuditStage)
#elseif Approval_DEV
            _ = KeychainManager.share.setDomainMode(.AuditDev)
#elseif Approval_QA
            _ = KeychainManager.share.setDomainMode(.AuditQa)
#endif
        }
#if Mundo_PRO
        self.domainMode = .Pro
#elseif Mundo_STAGE
        self.domainMode = .Stage
#elseif Approval_PRO
        self.domainMode = .AuditPro
#elseif Approval_STAGE
        self.domainMode = .AuditStage
#else
        self.domainMode = KeychainManager.share.getDomainMode()
        Toast.show(msg: "目前是 \(self.domainMode.rawValue) 環境\n 域名:\(BuildConfig.Domain)")
#endif
        DropDown.startListeningToKeyboard()
        
#if Mundo_PRO
        // 啟動Firebase GA
        FirebaseApp.configure()
#else
#endif
    }
    func isLaunchBefore() -> Bool {
        let isLaunchBefore = UserDefaults.Verification.bool(forKey: .launchBefore)
        if !isLaunchBefore {
            UserDefaults.Verification.set(value: true, forKey: .launchBefore)
        }
        return isLaunchBefore
    }
    func checkAppVersion() {
      
    }
//    func checkAddressbook() {
//        CheckTokenService.share.checkAddressBookWhiteListEnabled { data in
//            
//        }
//    }
    func checkTime(complete:CheckCompletionBlock? = nil)
    {
        // 打API 檢查是否過期
#if Approval_PRO || Approval_DEV || Approval_STAGE
        checkAuditToken(complete: complete)
#else
        checkMundocoinAPIToken(complete: complete)
#endif
    }
    func freshAuditToken()
    {
        Log.v("刷新AuditToken")
    }
    func checkAuditToken(complete:CheckCompletionBlock? = nil)
    {
        // 確定有否過期,再導去登入頁面
        CheckTokenService.share
            .checkTokenExpired(complete: complete)
    }
    func checkMundocoinAPIToken(complete:CheckCompletionBlock? = nil)
    {
        // 確定有否過期,再導去登入頁面
        CheckTokenService.share
            .checkTokenExpired(complete: complete)
    }
    func freshToken()
    {
        CheckTokenService.share
            .freshToken()
    }
    func startToCountDown()
    {
        CheckTokenService.share
            .startToCountDown()
    }
    func stopRETimer()
    {
        CheckTokenService.share
            .stopRETimer()
    }
}
// MARK: -
// MARK: 延伸 背景執行
extension AppDelegate {
    func initBackgroundTasktimer()
    {
        self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler:
                                                                                    {
            Log.i("背景執行 計時過期: Your app will not be executing code in background anymore.")
            
            if let indentifier = self.backgroundTaskIdentifier
            {
                self.timer?.invalidate()
                self.timer = nil
                UIApplication.shared.endBackgroundTask(indentifier)
            }
        })
    }
    func endBackgroundTasksWillEnterForeground(_ application: UIApplication)
    {
        Log.i("背景執行 結束於進入前景")
        self.timer?.invalidate()
        self.timer = nil
        self.bgTimer?.invalidate()
        if let indentifier = self.backgroundTaskIdentifier
        {
            application.endBackgroundTask(indentifier)
            UIApplication.shared.endBackgroundTask(indentifier)
        }
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundAppRefreshTaskSchedulerIdentifier)
            Log.i("背景執行 part2 :Cancel task request")
        } else {
            // Fallback on earlier versions
        }
    }
    func backgroundTaskTenMins()
    {
        var countInt = 500
        bgTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            countInt -= 1
            Log.i("背景執行 自然倒數: \(countInt)")
            DispatchQueue.main.async {
                // 先關起來
//                Log.e("剩餘時間 : \(countInt) 秒")
                if countInt == 0 {
                    timer.invalidate()
                    Log.i("背景執行 自然倒數結束")
                    if let indentifier = strongSelf.backgroundTaskIdentifier
                    {
                        UIApplication.shared.endBackgroundTask(indentifier)
                    }
                }
            }
        }
        bgTimer?.fire()
//        DispatchQueue.main.asyncAfter(deadline:.now() + 500)
//        {
//            Log.i("背景執行 自然倒數結束")
//            if let indentifier = self.backgroundTaskIdentifier
//            {
//                UIApplication.shared.endBackgroundTask(indentifier)
//            }
//        }
    }
    func submitBackgroundTasks() {
        if #available(iOS 13.0, *) {
            // Declared at the "Permitted background task scheduler identifiers" in info.plist

            let timeDelay = 10.0
            
            do {
                let backgroundAppProcessingTaskRequest = BGProcessingTaskRequest(identifier: backgroundProcessingTaskSchedulerIdentifier)
                backgroundAppProcessingTaskRequest.requiresNetworkConnectivity = true
                backgroundAppProcessingTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: timeDelay)
                let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: backgroundAppRefreshTaskSchedulerIdentifier)
                backgroundAppRefreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: timeDelay)
                try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
                try BGTaskScheduler.shared.submit(backgroundAppProcessingTaskRequest)
                Log.i("背景執行 part2 :Submitted task request")
            } catch {
                Log.i("背景執行 part2 :Failed to submit BGTask")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func registerBackgroundTasks() {
        initBackgroundTasktimer()
        if #available(iOS 13.0, *) {
            // Declared at the "Permitted background task scheduler identifiers" in info.plist
            // Use the identifier which represents your needs
            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundAppRefreshTaskSchedulerIdentifier, using: nil) { (task) in
                Log.i("背景執行 part2 :BackgroundAppRefreshTaskScheduler is executed NOW!")
                Log.i("背景執行 part2 :Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
                task.expirationHandler = {
                    task.setTaskCompleted(success: false)
                }
                
                // Do some data fetching and call setTaskCompleted(success:) asap!
                let isFetchingSuccess = true
                task.setTaskCompleted(success: isFetchingSuccess)
            }
            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundProcessingTaskSchedulerIdentifier, using: nil) { (task) in
                Log.i("背景執行 part2 :BackgroundAppProcessingTaskScheduler is executed NOW!")
                Log.i("背景執行 part2 :Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
                task.expirationHandler = {
                    task.setTaskCompleted(success: false)
                }
                
                // Do some data fetching and call setTaskCompleted(success:) asap!
                let isFetchingSuccess = true
                task.setTaskCompleted(success: isFetchingSuccess)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
// MARK: -
// MARK: 延伸 有否越獄
extension AppDelegate
{
    func showAlertForJillbreakDevice(withVC vc:UIViewController)
    {
        let textString = "It has been detected that your mobile phone has a connection risk. In order to protect the security of your account, this service is temporarily closed."
        let stringHeight = textString.height(withConstrainedWidth: (Views.screenWidth - 116), font: Fonts.PlusJakartaSansMedium(16))
        let popVC = ConfirmPopupView(viewHeight:stringHeight + 130 ,iconMode: .nonIcon(["OK".localized]),
                                      title: "",
                                      message: textString) { isOK in

            if isOK {
                Log.i("越獄機器")
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }else
            {
                
            }
        }
        popVC.start(viewController: vc)
    }
    func detectIsJialbrokenDevice() -> Bool
    {
        if isCydiaAppInstalled() == true
           || isJailBrokenFilesPresentInTheDirectory() == true
           || AppDelegate.canEditSandboxFilesForJailBreakDetecttion() == true
        {
            return true
        }else
        {
//            return true
            return false
        }
    }
    func isCydiaAppInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
    }
    func isJailBrokenFilesPresentInTheDirectory() -> Bool {
        let fm = FileManager.default
        if(fm.fileExists(atPath: "/private/var/lib/apt")) || (fm.fileExists(atPath: "/Applications/Cydia.app"))
        {
            // This Device is jailbroken
            return true
        } else {
            // Continue the device is not jailbroken
            return false
        }
    }
    static func canEditSandboxFilesForJailBreakDetecttion() -> Bool {
        let jailBreakTestText = "Test for JailBreak"
        do {
            try jailBreakTestText.write(toFile:"/private/jailBreakTestText.txt", atomically:true, encoding:String.Encoding.utf8)
            return true
        } catch {
            return false
        }
    }
}
// MARK: -
// MARK: 延伸
extension AppDelegate :UNUserNotificationCenterDelegate
{
    // 在前景收到通知時所觸發的 function
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Log.socket("Socket.io - 在前景收到通知...")
        completionHandler([.badge, .sound, .alert])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content: UNNotificationContent = response.notification.request.content
        
        completionHandler()
        
        // 取出userInfo的link並開啟Facebook
        if let linkString = content.userInfo["link"] as? String , let requestUrl = URL(string: linkString)
        {
            UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
        }
        if let requestUrl = content.userInfo["deeplink"] as? String
        {
            if requestUrl == "wallet"
            {
                DeepLinkManager.share.handleDeeplink(navigation: .wallet)
            }else
            {
                Log.v("不知道去哪 \(requestUrl)")
            }
        }
    }
}
