//
//  CheckTokenExpiredService.swift
//  cryptoVerOne
//
//  Created by BBk on 7/6/22.
//

import UIKit
import Toaster
import RxSwift
import RxCocoa
import DropDown
import JWTDecode

public enum SectionExpired {
    case inSection
    case lightLogout
    case forceLogout
}
class CheckTokenService{
    // MARK:業務設定
    var timer: Timer?
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static var share = CheckTokenService()
    // MARK: -
    // MARK:UI 設定
   
    // MARK: -
    // MARK:Life cycle
    
    // MARK: -
    // MARK:業務方法
    // 檢查 token 是否過期
    func checkTokenExpired(complete:CheckScetionCompletionBlock? = nil)
    {
        KeychainManager.share.saveLightLogoutMode(false)
        let token = KeychainManager.share.getToken()
        // 準備好 id 資料
        var jwtValue :JWT!
        do {
            jwtValue = try decode(jwt: token)
        } catch {
            Log.v("AppDelegate - Failed to decode JWT: \(error)")
            KeychainManager.share.saveFinishLaunchActive(false)
            if let successBlock = complete
            {
                successBlock(.forceLogout)
            }else
            {
                //過期去登入頁面
                goToLoginVC()
            }
        }
#if Approval_PRO || Approval_DEV || Approval_STAGE
        KeychainManager.share.saveFinishLaunchActive(false)
        if jwtValue != nil , let isExpired = jwtValue?.expired
        {
            if isExpired == false
            {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    // 沒過期,打refresh API, 時間加30分鐘
                    //            SocketIOManager.sharedInstance.establishConnection()
                    SocketIOManager.sharedInstance.reConnection()
                    Log.v("Token 沒過期")
                    if let successBlock = complete
                    {
                        successBlock(.inSection)
                    }else
                    {
                        freshToken()
                    }
                }
            }else
            {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    Log.v("Token 過期")
                    if let successBlock = complete
                    {
                        successBlock(.forceLogout)
                    }else
                    {
                        //過期去登入頁面
                        goToLoginVC()
                    }
                }
            }
        }
#else
        let sectionMin = Int(KeychainManager.share.getSectionMin() ?? "0") ?? 0
        let sectionDay = Int(KeychainManager.share.getSectionDay() ?? "0") ?? 0
        let lastEnterBGDate = getEnterBGtime()
        let isExpiredInMins = lastEnterBGDate.isInMins(min: sectionMin)
        let isExpiredInDays = lastEnterBGDate.isInDays(day: sectionDay)
        let isfirstLuanch = UserDefaults.isFirstLaunch()
        if jwtValue != nil , let _ = jwtValue?.expired
        {
            if isExpiredInDays == false || isfirstLuanch == true
            {
                Log.v("在 \(sectionDay) 天後")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    Log.v("Token 過期")
                    KeychainManager.share.saveFinishLaunchActive(false)
                    subBlockForSection(complete:complete ,section: .forceLogout)
                }
            }else if isExpiredInMins == false , isExpiredInDays == true
            {
                KeychainManager.share.saveFinishLaunchActive(false)
                Log.v("在 \(sectionMin) 分後, \(sectionDay) 天內" )
                if let accountString = KeychainManager.share.getLastAccount()
                {
                    Log.v("上次帳號 : \(accountString)")
                    KeychainManager.share.saveLightLogoutMode(true)
                    subBlockForSection(complete:complete ,section: .lightLogout)
                }
            }else
            {
                KeychainManager.share.saveFinishLaunchActive(false)
                //使用者自己滑掉 或 重新啟動
//                if KeychainManager.share.getTerminateByUser() == true ||
//                    KeychainManager.share.getFinishLaunchActive() == true
//                {
//                    Log.v("是否使用者自己滑掉 : \(KeychainManager.share.getTerminateByUser())\n是否重新啟動 :\(KeychainManager.share.getFinishLaunchActive())" )
//                    if let accountString = KeychainManager.share.getLastAccount()
//                    {
//                        Log.v("上次帳號 : \(accountString)")
//                        KeychainManager.share.saveLightLogoutMode(true)
//                        subBlockForSection(complete:complete ,section: .lightLogout)
//                    }
//                }else{
//                }
                
                Log.v("在 \(sectionMin) 分內")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    // 沒過期,打refresh API, 時間加30分鐘
                    SocketIOManager.sharedInstance.reConnection()
                    subBlockForSection(complete:complete ,section: .inSection)
                }
            }
        }
#endif
    }
    func subBlockForSection(complete:CheckScetionCompletionBlock? = nil , section:SectionExpired)
    {
        if let successBlock = complete
        {
            successBlock(section)
        }else
        {
            switch section {
            case .forceLogout:
                Log.v("Token 過期")
                if let successBlock = complete
                {
                    successBlock(.forceLogout)
                }else
                {
                    //過期去登入頁面
                    goToLoginVC()
                }
            case .lightLogout:
                // 去淺登出
                Log.v("淺登出狀態")
                SocketIOManager.sharedInstance.closeConnection()
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
                {
                    let vc = LaunchReciprocalViewController.instance(sectionflag: .lightLogout)
                    mainWindow.rootViewController = vc
                    mainWindow.makeKeyAndVisible()
                }
            case .inSection:
                Log.v("Token 沒過期")
                if let successBlock = complete
                {
                    successBlock(.inSection)
                }else
                {
                    freshToken()
                }
            }
        }
    }
    func getEnterBGtime() -> Date
    {
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter1.timeZone = .current
        formatter1.locale = .current
        let todayTimeString = formatter1.string(from: today)
        Log.i(todayTimeString)
        
        let currentTimeString = KeychainManager.share.getEnterBGtime()!.isEmpty ? todayTimeString : KeychainManager.share.getEnterBGtime()
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter2.timeZone = .current
        formatter2.locale = .current
        let currentDate = formatter2.date(from:currentTimeString!)
        
        var calendar = Calendar.current
        calendar.timeZone = .current

        let componentsEnterBG = calendar.dateComponents([.year, .month, .day, .hour,.minute,.second], from: currentDate!)
        let enterBGDate = calendar.date(from:componentsEnterBG)!
        Log.i(enterBGDate)
        return enterBGDate
    }
    // 下載資料
    func fetchCurrencyInfo()
    {
        Beans.infoServer.fetchCurrencySettings().subscribeSuccess { dataDto in
            if let _ = dataDto.first
            {
                MemberAccountDto.share?.currencySettings = dataDto
            }
        }.disposed(by: dpg)
    }
    // 儲存Token到 MemberAccountDto
    func parseTokenToMemberAccountDto(complete:CheckCompletionBlock? = nil)
    {
        let token = KeychainManager.share.getToken()
        // 準備好 id 資料
        var jwtValue :JWT!
        do {
            jwtValue = try decode(jwt: token)
        } catch {
            Log.v("AppDelegate - Failed to decode JWT: \(error)")
            if let successBlock = complete
            {
                successBlock(false)
            }else
            {
                //過期去登入頁面
                goToLoginVC()
            }
        }
        if jwtValue != nil ,
            let isAccountLocked = jwtValue.body["isAccountLocked"] as? Bool,
           let registrationDate = jwtValue.body["registrationDate"] as? Int,
           let Id = jwtValue.body["Id"] as? String,
           let isAccountEnabled = jwtValue.body["isAccountEnabled"] as? Bool,
           let isAddressBookWhiteListEnabled = jwtValue.body["isAddressBookWhiteListEnabled"] as? Bool,
           let isPasswordExpired = jwtValue.body["isPasswordExpired"] as? Bool
            ,
            let sub = jwtValue.body["sub"] as? String,
           let isAccountExpired = jwtValue.body["isAccountExpired"] as? Bool
        {
            MemberAccountDto.share = MemberAccountDto(isAccountLocked: isAccountLocked,
                                                      registrationDate: registrationDate,
                                                      Id: Id,
                                                      isAccountEnabled: isAccountEnabled,
                                                      isAddressBookWhiteListEnabled: isAddressBookWhiteListEnabled,
                                                      isPasswordExpired: isPasswordExpired,
                                                      sub: sub,
                                                      isAccountExpired: isAccountExpired)
        }
        if let email = jwtValue.body["email"] as? String
        {
            MemberAccountDto.share?.email = email
        }
        if let phone = jwtValue.body["phone"] as? String
        {
            MemberAccountDto.share?.phone = phone
        }
        if let nickname = jwtValue.body["nickname"] as? String
        {
            MemberAccountDto.share?.nickName = nickname
        }
        if let isPhoneRegistry = jwtValue.body["isPhoneRegistry"] as? Bool,
           let isEmailRegistry = jwtValue.body["isEmailRegistry"] as? Bool
        {
            MemberAccountDto.share?.isPhoneRegistry = isPhoneRegistry
            MemberAccountDto.share?.isEmailRegistry = isEmailRegistry
//            if isPhoneRegistry
//            {
//                let phoneAccountString = MemberAccountDto.share?.phone ?? ""
//                KeychainManager.share.setLastAccount(phoneAccountString)
//            }else
//            {
//                let emailAccountString = MemberAccountDto.share?.email ?? ""
//                KeychainManager.share.setLastAccount(emailAccountString)
//            }
        }
        KeychainManager.share.saveAccPwd(acc: MemberAccountDto.share?.email ?? "",
                                         phone: MemberAccountDto.share?.phone ?? "")
    }
    // 檢查 白名單 isAddressBookWhiteListEnabled
    func checkAddressBookWhiteListEnabled(complete:CheckCompletionBlock? = nil)
    {
        let token = KeychainManager.share.getToken()
        // 準備好 id 資料
        var jwtValue :JWT!
        do {
            jwtValue = try decode(jwt: token)
        } catch {
            Log.v("AppDelegate - Failed to decode JWT: \(error)")
            if let successBlock = complete
            {
                successBlock(false)
            }else
            {
                //過期去登入頁面
                goToLoginVC()
            }
        }
        if jwtValue != nil , let isAddressBookWhiteListEnabled = jwtValue.body["isAddressBookWhiteListEnabled"] as? Bool
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { 
                if (isAddressBookWhiteListEnabled == false)
                {
                    Log.v("白名單 不啟用")
                }else
                {
                    Log.v("白名單 啟用")
                }
                
                if let successBlock = complete
                {
                    successBlock(isAddressBookWhiteListEnabled)
                }
                KeychainManager.share.saveWhiteListOnOff(isAddressBookWhiteListEnabled)
                WhiteListThemes.share.acceptWhiteListTopImageStyle(isAddressBookWhiteListEnabled == true ? .whiteListOn : .whiteListOff)
            }
        }
    }
    // 檢查 白名單 isAddressBookWhiteListEnabled
    func checkAuth(complete:CheckCompletionBlock? = nil)
    {
        let token = KeychainManager.share.getToken()
        // 準備好 id 資料
        var jwtValue :JWT!
        do {
            jwtValue = try decode(jwt: token)
        } catch {
            Log.v("AppDelegate - Failed to decode JWT: \(error)")
            if let successBlock = complete
            {
                successBlock(false)
            }else
            {
                //過期去登入頁面
                gotoAuditLoginVC()
            }
        }
        if jwtValue != nil , let permissions = jwtValue.body["permissions"] as? Array<[String:Any]>
        {
            Log.e("\(permissions)")
            for permissionData in permissions
            {
                if permissionData["name"] as! String == "APP" ,
                   let features = permissionData["features"] as? Array<[String:Any]>
                {
                    for item in features {
                        if (item["feature"] as! String) == "WITHDRAW_APPROVAL" ,
                           let levelArray = item["level"] as? Array<String>
                        {
                            if levelArray.contains("READABLE")
                            {
                                KeychainManager.share.setReadable("READABLE")
                            }else
                            {
                                KeychainManager.share.setReadable("")
                            }
                            if levelArray.contains("EDITABLE")
                            {
                                KeychainManager.share.setEditable("EDITABLE")
                            }else
                            {
                                KeychainManager.share.setEditable("")
                            }
                        }
                    }
                }
            }
        }
    }
    func gotoAuditLoginVC()
    {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
        {
            DeepLinkManager.share.cleanDataForLogout()
            let auditNavVC = MDNavigationController(rootViewController: AuditLoginViewController.loadNib())
            mainWindow.rootViewController = auditNavVC
            mainWindow.makeKeyAndVisible()
        }
    }
    func goToLoginVC()
    {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        DeepLinkManager.share.handleDeeplink(navigation: .auditLogin)
#else
        DeepLinkManager.share.handleDeeplink(navigation: .login)
#endif
    }
    func freshToken()
    {
        Log.v("刷新Token")
        #if Approval_PRO || Approval_DEV || Approval_STAGE
        Log.v("查詢權限")
        checkAuth()
        #else
        Beans.loginServer.refreshToken().subscribeSuccess { [self] dto in
            if let dataDto = dto
            {
                KeychainManager.share.setToken(dataDto.token)
                // 刷新MemberAccount
                parseTokenToMemberAccountDto()
                // 刷新時間
                startToCountDown()
                // 刷新InfoData
                fetchCurrencyInfo()
            }
        }.disposed(by: dpg)
        #endif
    }
    func startToCountDown() {
        Log.v("刷新時間")
        stopRETimer()
        Log.v("確定白名單功能")
        checkAddressBookWhiteListEnabled()
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
        timer?.invalidate()
        timer = nil
    }
}
