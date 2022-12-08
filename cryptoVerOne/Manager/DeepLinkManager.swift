//
//  DeepLinkManager.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import UIKit
import RxSwift

class DeepLinkManager {
    static let share = DeepLinkManager()
    
    var navigation: Navigation = .none
    private var completion: (() -> ())?
    static let typeNames = ["app_MainPage",
                            "app_Promotion",
                            "app_Promotion_Content",
                            "app_Wallet_Deposit",
                            "app_Wallet_Withdrawal",
                            "app_Member",
                            "app_Member_MyPromotion",
                            "app_Promotion_Detail",
                            "app_Login",
                            "app_Signup",
                            "​​app_News",
                            "​​/my/personal"]
    
    
    
    func parserUrlFromBroeser(_ url: URL?) {
        guard let url = url else { return }
        print("parser url from browser: \(url.absoluteString)")
        let host = url.host ?? ""
        let path = url.path
        let parameter = url.queryDictionary
        print("url domain: \(host) + \(path)")
        print("url path parameters: \(parameter ?? [:])")
        
        if parameter != nil {
            if let type = parameter?["type"] {
                if type == "account" { // 登入註冊相關
                    navigation = Navigation(typeName: parameter?["card"] ?? "")
                } else {
                    navigation = Navigation(typeName: "\(type)")
                }
            } else if let type = parameter?["card"] {
                if type == "bl_News" && parameter?["id"] != nil { // 指定公告
                    navigation = Navigation(typeName: "\(type)", id: (parameter?["id"])!)
                } else if type == "bl_popPromotion" && parameter?["id"] != nil { // 指定優惠內容
                    navigation = Navigation(typeName: "\(type)", id: (parameter?["id"])!)
                } else if type == "bl_popPromotionDetail" && parameter?["promotion_id"] != nil { // 指定優惠明細
                    navigation = Navigation(typeName: "\(type)", id: (parameter?["promotion_id"])!)
                } else { // 目前應該只有公告列表 bl_News
                    navigation = Navigation(typeName: "\(type)")
                }
            } else if let type = parameter?["url"] { // 開啟網頁 app 內或外
                navigation = Navigation(typeName: path, id: type)
            }
            handleDeeplink(navigation: self.navigation)
            return
        }
        // 不需要帶parameter的頁面
        navigation = Navigation(typeName: "\(path)")
        handleDeeplink(navigation: self.navigation)
    }
    
    func handleDeeplink(navigation: DeepLinkManager.Navigation) {
        self.navigation = navigation
        backToTabbarVC { [weak self] in
            print("navigation to: \(navigation)")
            switch navigation {
            case .member,.walletDeposit, .walletWithdrawal:
                if !UserStatus.share.isLogin {
                    DispatchQueue.main.async {
                        LoginSignupViewController.share.willShowAgainFromVerifyVC = false
                        let loginNavVC = MuLoginNavigationController(rootViewController: LoginSignupViewController.share.showMode(.loginEmail))
                        UIApplication.shared.keyWindow?.rootViewController = loginNavVC
                    }
                } else {
                    DispatchQueue.main.async {
                        navigation.toTargetVC()
                        self?.navigation = .none
                    }
                }
            default:
                DispatchQueue.main.async {
                    navigation.toTargetVC()
                    self?.navigation = .none
                }
            }
        }
    }
    
    func backToTabbarVC(_ done: @escaping (() -> ())) {
        completion = {
            print("top vc completion.")
            done()
        }
        toTopVC()
    }
    
    func toTopVC() {
        
        if let vc = UIApplication.topViewController() {
            print("current top vc: \(vc)")
            if vc.isKind(of: LaunchReciprocalViewController.self) { return }
            if vc.isKind(of: LoginSignupViewController.self) { return }
            if vc.isKind(of: AuditLoginViewController.self) { return }
            if !vc.isKind(of: TabbarViewController.self) {
//                if vc.navigationController == nil {
//                    vc.dismiss(animated: false) {
//                        DispatchQueue.main.async {
//                            self.toTopVC()
//                        }
//                    }
//                } else {
//                    vc.navigationController?.popToRootViewController(animated: true)
//                    toTopVC()
//                }
                vc.navigationController?.popToRootViewController(animated: true)
                completion?()
            } else if !vc.isKind(of: AuditTabbarViewController.self){
                vc.navigationController?.popToRootViewController(animated: true)
                completion?()
            }else
            {
                print("current vc is tabbar vc finished.")
                completion?()
            }
        }
    }
    func cleanDataForLogout()
    {
        KeychainManager.share.clearToken()
        WalletAddressDto.share = nil
        UserInfoDto.share = nil
        RegistrationDto.share = nil
        SocketIOManager.sharedInstance.closeConnection()
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.stopRETimer()
        }
    }
}
fileprivate let dpg = DisposeBag()
// MARK: enum
extension DeepLinkManager {
    
    enum LinkType {
        case url(String)
        case apns(String)
    }
    
    @available(iOS 10.0, *)
    enum Navigation: Equatable {
        case main
        case wallet
        case promotion
        case promotionContent(String)
//        case myPromotion
//        case promotionDetail(String)
        case member
        case walletDeposit
        case walletWithdrawal
        case addressBook
        
        case login
        case signup
        
        case auditLogin
        case auditLoginWithUnAuthorized(String)
        
        case none
        case appNews
        case news(String)
        case service
        case inapp(String)
        case outapp(String)
        case memberShowWallet
        
//        case txRecord(TxRecordViewController.TxRecordType)
        
        init(typeName: String, id: String? = nil) {
            self = Navigation.match(typeName: typeName, id: id)
        }
        
        static func match(typeName: String, id: String? = nil) -> Navigation {
            
            switch typeName {
            case "app_MainPage": return .main
            case "": return .wallet
            case "app_Promotion", "/promotion": return .promotion
            case "app_Promotion_Content", "bl_popPromotion": return .promotionContent(id ?? "-1")
            case "app_Wallet_Deposit", "deposit": return .walletDeposit
            case "app_Wallet_Withdrawal", "withdrawal": return .walletWithdrawal
            case "app_Member", "/my/personal": return .member
//            case "app_Member_MyPromotion", "/my/mypromotion": return .myPromotion
//            case "app_Promotion_Detail","bl_popPromotionDetail": return .promotionDetail(id ?? "-1")
            case "app_Login", "bl_Login": return .login
            case "app_Signup", "bl_Register": return .signup
            case "​​app_News", "bl_News":
                if id != nil {
                    return .news(id!)
                }
                return .appNews
            case "/inapp": return .inapp(id!)
            case "/outapp": return .outapp(id!)
            default: return .none
            }
        }
        
        static func parser(for linkType: LinkType) -> String {
            switch linkType {
            case .apns(let key):
                print("apns deeplink key: \(key)")
                return "key"
            case .url(let urlStr):
                print("link from url: \(urlStr)")
                return "key"
            }
        }
        
        func toTargetVC() {
            switch self {
            case .main:
                print("main")
                guard let vc = getBaseTabbarVC() else { return }
                vc.selected(0)
            case .wallet:
                print("main")
                guard let vc = getBaseTabbarVC() else { return }
                vc.selected(1)
            case .promotion:
                print("promotion")
                guard let vc = getBaseTabbarVC() else { return }
                vc.selected(2)
                
            case .promotionContent(let id):
                print("promotion Content")
                guard let vc = getBaseTabbarVC(), let _ = Int(id) else { return }
                vc.selected(2)
//                Beans.promotionServer.getPromotion(id: id).subscribeSuccess { (dto) in
//                    let promotionContentSheet = PromotionContentBottomSheet()
//                    promotionContentSheet.configure(promotionDto: dto)
//                    DispatchQueue.main.async {
//                        promotionContentSheet.start(viewController: vc)
//                    }
//                }.disposed(by: dpg)
                
//            case .promotionDetail(let id):
//                print("promotion Detail")
//                guard let vc = getBaseTabbarVC(), let id = Int(id)  else { return }
//                vc.selected(3)
//                vc.navigationController?.pushViewController(MyPromotionViewController(), animated: false)
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
//                    self.showPromotionDetail(vc: vc, id: id)
//                }
                
//            case .myPromotion:
//                print("my Promotion")
//                guard let vc = getBaseTabbarVC() else { return }
//                vc.selected(3)
//                vc.navigationController?.pushViewController(MyPromotionViewController(), animated: true)
                
            case .member:
                print("member")
                guard let vc = getBaseTabbarVC() else { return }
                vc.selected(3)
                
            case .memberShowWallet: break
//                guard let vc = getBaseTabbarVC() else { return }
//                vc.memberVC.setMoneyViewExpand()
//                vc.selected(3)
                
//            case .txRecord(let type):
//                print("tx record type:\(type)")
//                guard let vc = getBaseTabbarVC() else { return }
//                vc.selected(3)
//                let recordVC = showTxRecordVC(recordType: type)
//                vc.navigationController?.pushViewController(recordVC, animated: true)
                
            case .walletDeposit:
                print("wallet Deposit")
                guard let vc = getBaseTabbarVC() else { return }
                vc.selected(1)
//                vc.navigationController?.pushViewController(MyPromotionViewController(), animated: true)
            
            case .walletWithdrawal:
                print("wallet Withdrawal")
                guard let vc = getBaseTabbarVC() else { return }
                vc.selected(1)
            case .addressBook:
                print("go AddressBook")
                if let vc = UIApplication.topViewController()
                {
                    vc.dismiss(animated: false){
                        if let subVC = UIApplication.topViewController()
                        {
                            subVC.navigationController?.popViewController(animated: false)
                            if let newVC = UIApplication.topViewController() as? WalletViewController
                            {
                                newVC.pushToProfile(withCellData: .addressBook)
                            }
//                            guard let currentTabbarVC = getBaseTabbarVC() else { return }
//                            currentTabbarVC.selected(0)
                        }
                    }
                }
            case .login:
                print("login")
                DeepLinkManager.share.cleanDataForLogout()
                if let vc = UIApplication.topViewController()
                {
                    if vc.isKind(of: LoginSignupViewController.self) { return }
                    LoginSignupViewController.share.willShowAgainFromVerifyVC = false
                    let loginNavVC = MuLoginNavigationController(rootViewController: LoginSignupViewController.share.showMode(.loginEmail))
                    UIApplication.shared.keyWindow?.rootViewController = loginNavVC
                }
            case .signup:
                print("signup")
                DeepLinkManager.share.cleanDataForLogout()
                let loginNavVC = MuLoginNavigationController(rootViewController: LoginSignupViewController.share.showMode(.signupEmail))
                UIApplication.shared.keyWindow?.rootViewController = loginNavVC
            case .auditLogin:
                DeepLinkManager.share.cleanDataForLogout()
                if let vc = UIApplication.topViewController()
                {
                    if vc.isKind(of: AuditLoginViewController.self) { return }
                    let auditNavVC = MDNavigationController(rootViewController: AuditLoginViewController.loadNib())
                    UIApplication.shared.keyWindow?.rootViewController = auditNavVC
                }
            case .auditLoginWithUnAuthorized(let string):
                DeepLinkManager.share.cleanDataForLogout()
                if let vc = UIApplication.topViewController()
                {
                    if vc.isKind(of: AuditLoginViewController.self) { return }
                    let auditNavVC = MDNavigationController(rootViewController: AuditLoginViewController.loadNib())
                    UIApplication.shared.keyWindow?.rootViewController = auditNavVC
                    if let currentVC = UIApplication.topViewController()
                    {
                        let popVC = ConfirmPopupView(viewHeight:200.0 ,
                                                     iconMode: .nonIcon(["Close".localized]),
                                                     title: "",
                                                     message: string ){ _ in }
                        popVC.start(viewController: currentVC)
                    }
                }
            case .appNews:
                print("app news")
                guard let _ = getBaseTabbarVC() else { return }
//                NewsBottomSheet().start(viewController: vc)
                
            case .news(let id):
                guard let _ = getBaseTabbarVC(), let _ = Int(id) else { return }
//                Beans.newsServer.frontendNews(id: id).subscribeSuccess { (dto) in
//                    DispatchQueue.main.async {
//                        NewsDetailBottomSheet(newsDto: dto).start(viewController: vc)
//                    }
//                }.disposed(by: dpg)
                
            case .service:
                print("service")
            case .inapp(let urlStr):
                print("inapp url str: \(urlStr)")
                guard let _ = UIApplication.topViewController() else { return }
//                topVC.navigationController?.pushViewController(BetLeadWebViewController(urlStr), animated: true)
                
            case .outapp(let urlStr):
                print("outapp url str: \(urlStr)")
                  UIApplication.shared.open((URL(string: urlStr)!), options: [:], completionHandler: nil)
            default:
                print("none")
            }
            
        }
        
//        private func showTxRecordVC(recordType: TxRecordViewController.TxRecordType) -> TxRecordViewController {
//            let vc = TxRecordViewController()
//            vc.displayType = recordType
//            return vc
//        }
        
        func getBaseTabbarVC() -> TabbarViewController? {
            return UIApplication.topViewController() as? TabbarViewController
        }
        
//        func showPromotionDetail(vc: UIViewController, id: Int) {
//            LoadingViewController.show()
//            Beans.promotionServer.getMyPromotionDetail(promotion_id: id)
//                .subscribeSuccess { promotionDtos in
//                    guard let myPromotionDto = promotionDtos.first else { return }
//                    LoadingViewController.dismiss().subscribeSuccess({ (_) in
//                        switch myPromotionDto.promotionDto.applyPeriod {
//                        case .single:
//                            let newVC = PromotionDetailBottomSheet(myPromotionDto.promotionDto.id)
//                            newVC.start(viewController: vc)
//                        case .cycle:
//                            let newVC = MyPromotionCycleViewController(myPromotionDetailDtos: promotionDtos)
//                            newVC.setTitle(title: myPromotionDto.promotionDto.promotionTitle, subtitle: myPromotionDto.promotionDto.promotionSubTitle ?? "")
//                            vc.navigationController?.pushViewController(newVC, animated: true)
//                        case .unKnown:
//                            break
//                        }
//                    }).disposed(by: dpg)
//                }.disposed(by: dpg)
//        }
    }
}
