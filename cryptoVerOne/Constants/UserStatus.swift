//
//  UserStatus.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation

class UserStatus {
    static let share = UserStatus()
    var loginUserModel:LoginDto?
    var isLogin:Bool {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        return !KeychainManager.share.getAuditToken().isEmpty
#else
        return !KeychainManager.share.getToken().isEmpty
#endif
    }
    func detectIsLogin() -> Bool
    {
        return self.isLogin
    }
    var rToken:String
    {
        let lToken = self.loginUserModel?.token ?? ""
        return lToken
    }
    var rUID:String
    {
//        let uID = self.userModel?.id ?? 0
        let uID = UserInfoDto.share?.id ?? 0
        let lID = self.loginUserModel?.id ?? 0
        
        return (lID == 0) ? String(uID) : String(lID)
    }
}
