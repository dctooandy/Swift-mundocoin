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
    
    let loginVC =  LoginSignupViewController.share
    
    @IBOutlet weak var reciprocalLabel: UILabel!
    @IBOutlet weak var beleadLeftIcon:UIImageView!
    @IBOutlet weak var beleadRightTopIcon:UIImageView!
    @IBOutlet weak var beleadRightBottomIcon:UIImageView!
    @IBOutlet weak var copyrightLabel:UILabel!
    private var count = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkVersion()
        beleadLeftIcon.transform = CGAffineTransform(translationX: 0, y: 50)
        beleadRightTopIcon.transform = CGAffineTransform(translationX: -30, y: 0)
        beleadRightBottomIcon.transform = CGAffineTransform(translationX: -30, y: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startToCountDown()
        startAnimation()
    }
    
    func startToCountDown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            strongSelf.count -= 1
            DispatchQueue.main.async {
                print("倒數： \(strongSelf.count)")
                strongSelf.reciprocalLabel.text = "\(strongSelf.count) 秒"
                if strongSelf.count == 0 {
                    timer.invalidate()
                    strongSelf.directToViewController()
                }
            }
        }
    }
    
    func directToViewController() {
        if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
            if showUpdateAlert {
                appUpdateAlert()
                return
            }
//            if isLaunchBefore() {
            
            if UserStatus.share.isLogin == true {
                // 自動登入
                // 檢查token動作
                if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                    appdelegate.checkTime()
                }
                let walletVC = WalletViewController.share
                let walletNavVC = MDNavigationController(rootViewController: walletVC)
                mainWindow.rootViewController = walletNavVC
                mainWindow.makeKeyAndVisible()
            }else
            {
                let loginNavVC = MuLoginNavigationController(rootViewController: loginVC)
                mainWindow.rootViewController = loginNavVC
                mainWindow.makeKeyAndVisible()
            }
//            } else {
//                mainWindow.rootViewController = GuidePageViewController.loadNib()
//                mainWindow.makeKeyAndVisible()
//            }
        }
    }
    
    private func appUpdateAlert() {
        AppUpdateAlert(AppVersionDto.share) { [weak self](success) in
            
            if AppVersionDto.share != nil && AppVersionDto.share!.appVersionForceUpdate!.value! {
                return
            }
            self?.showUpdateAlert = false
            self?.directToViewController()
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
            self.beleadRightBottomIcon.alpha = 1
            self.beleadRightBottomIcon.transform = CGAffineTransform.identity
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
        
        // TODO: API
//        Beans.baseServer.appVersion()
//            .subscribeSuccess { [weak self] (dto) in
//                AppVersionDto.didFetch = true
//                AppVersionDto.share = dto
//                self?.showUpdateAlert = dto != nil
//            }.disposed(by: disposeBag)
    }
    
}


