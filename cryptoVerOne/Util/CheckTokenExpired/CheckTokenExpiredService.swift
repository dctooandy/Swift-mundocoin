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

class CheckTokenExpiredService{
    // MARK:業務設定
    var timer: Timer?
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static var share = CheckTokenExpiredService()
    // MARK: -
    // MARK:UI 設定
   
    // MARK: -
    // MARK:Life cycle
    
    // MARK: -
    // MARK:業務方法
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
        #else
        Beans.loginServer.refreshToken().subscribeSuccess { [self]dto in
            if let dataDto = dto
            {
                KeychainManager.share.setToken(dataDto.token)
                // 刷新時間
                startToCountDown()
            }
        }.disposed(by: dpg)
        #endif
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
        timer?.invalidate()
        timer = nil
    }
}