//
//  CheckTokenExpiredService.swift
//  cryptoVerOne
//
//  Created by BBk on 7/6/22.
//

import UIKit
import Toaster
import RxSwift
import DropDown
import JWTDecode

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
    func checkTokenExpired(complete:CheckCompletionBlock? = nil)
    {
        let token = KeychainManager.share.getToken()
        // 準備好 id 資料
        var jwtValue :JWT!
        do {
            jwtValue = try decode(jwt: token)
        } catch {
            Log.i("AppDelegate - Failed to decode JWT: \(error)")
            if let successBlock = complete
            {
                successBlock(false)
            }else
            {
                //過期去登入頁面
                goToLoginVC()
            }
        }
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
                        successBlock(true)
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
                        successBlock(false)
                    }else
                    {
                        //過期去登入頁面
                        goToLoginVC()
                    }
                }
            }
        }
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
            Log.i("AppDelegate - Failed to decode JWT: \(error)")
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
        }
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
            Log.i("AppDelegate - Failed to decode JWT: \(error)")
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
            Log.i("AppDelegate - Failed to decode JWT: \(error)")
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
