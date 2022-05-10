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
}

