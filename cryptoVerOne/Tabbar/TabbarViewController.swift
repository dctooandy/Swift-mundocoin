//
//  TabbarViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import UIKit
import RxSwift

class TabbarViewController:BaseViewController {
    
    lazy var mainPageVC:MainViewController = {
        let vc = MainViewController.loadNib()
        return vc
    }()
    lazy var walletPageVC:MDNavigationController = {
        let walletVC = WalletViewController.loadNib()
        let walletNavVC = MDNavigationController(rootViewController: walletVC)
        let vc = walletNavVC
        return vc
    }()
    lazy var promoteVC:PromotionViewController = {
        let vc = PromotionViewController()
        return vc
    }()
    lazy var memberVC: MemberViewController = {
        let vc = MemberViewController.loadNib()
        return vc
    }()
    
    private let tabbar = BaseTabbar.loadNib()
    
     init() {
        super.init()
        initData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initData()
    }
    private func initData(){
        setupTabbar()
        settingViewControllers()
        bindTabbar()
        bindFanmenu()
        tabbar.selected(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupTabbar(){
        view.addSubview(tabbar)
//        tabbar.setupFanMenu()
        tabbar.snp.makeConstraints { (maker) in
            maker.leading.bottom.trailing.equalToSuperview()
            maker.height.equalTo(Views.baseTabbarHeight)
        }
    }
    private func settingViewControllers() {
//        addChild(mainPageVC)
        addChild(walletPageVC)
//        addChild(promoteVC)
//        addChild(memberVC)
//        view.addSubview(mainPageVC.view)
        view.addSubview(walletPageVC.view)
//        view.addSubview(promoteVC.view)
//        view.addSubview(memberVC.view)
        walletPageVC.view.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(strongSelf.tabbar.snp.top)
        }
    }
    private func bindTabbar(){
        tabbar.rxItemClick.subscribeSuccess {[weak self](index) in
            guard let weakSelf = self else { return }
            if !UserStatus.share.isLogin && index > 1 {
                weakSelf.present(LoginAlert(), animated: true, completion: nil)
                return
            }
            weakSelf.statusStyle = .default
            switch index {
            case 0:
                weakSelf.statusStyle = .default
                weakSelf.view.bringSubviewToFront(weakSelf.mainPageVC.view)
                weakSelf.mainPageVC.didMove(toParent: self)
                weakSelf.checkDailyBanner()
            case 1:
                weakSelf.view.bringSubviewToFront(weakSelf.walletPageVC.view)
                weakSelf.walletPageVC.didMove(toParent: self)
            case 2:
                weakSelf.view.bringSubviewToFront(weakSelf.promoteVC.view)
                weakSelf.promoteVC.didMove(toParent: self)
            case 3:
                weakSelf.view.bringSubviewToFront(weakSelf.memberVC.view)
                weakSelf.memberVC.didMove(toParent: self)
            default:
                break
            }
            weakSelf.tabbar.bringToFront()
        }.disposed(by: disposeBag)
    }
    func selected(_ index:Int) {
        tabbar.selected(index)
    }
    
    private func bindFanmenu() {
        tabbar.rxMenuClick.subscribeSuccess { (menuType) in
            guard let topVC = UIApplication.topViewController() else { return }
            if menuType == .service {
//                LiveChatService.share.betLeadServicePresent()
                return
            }
//            topVC.present(BetLeadWebViewController(menuType.urlStr), animated: true, completion: nil)
            print("跳出客服")
        }.disposed(by: disposeBag)
    }
    
    private var appLaunch = true
    func checkDailyBanner() {
        
        if appLaunch {
            print("is app first launch. don't need to open full banner.")
            appLaunch = false
            return
        }
        if DeepLinkManager.share.navigation != .none { return }
        let lastDate = UserDefaults.Verification.string(forKey: .fullBanner)
        let today = Date().toString(format: "YYYY-MM-dd")
        let didOpen = lastDate == today
        if didOpen { return }
        print("open daily banner")
        fetchDailyBanners()
    }
    
    func fetchDailyBanners() {
//        Beans.bannerServer.fetchDailyBanner().subscribeSuccess { [weak self] (dtos) in
//            UserDefaults.Verification.set(value: Date().toString(format: "YYYY-MM-dd"),
//                                          forKey: .fullBanner)
//            if dtos.isEmpty { return }
//            let fullBanner = FullBanner()
//            fullBanner.bannerDto = dtos
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
//                self?.present(fullBanner, animated: true, completion: nil)
//            }
//        }.disposed(by: disposeBag)
    }
}
