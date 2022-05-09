//
//  LoginMode.swift
//  betlead
//
//  Created by Victor on 2019/10/2.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
enum LoginMode {
    case phone
    case account
    
    func accountPlacehloder() -> String {
        switch self {
        case .account: return "...@mundo.com"
        case .phone: return ""
        }
    }
    func pwdPlaceholder() -> String {
        switch self {
        case .account: return "********"
        case .phone: return "********"
        }
    }
    
    func signupAccountPlacehloder() -> String {
        switch self {
        case .account: return "...@mundo.com"
        case .phone: return ""
        }
    }
    
    func signupPwdPlaceholder() -> String {
        switch self {
        case .account: return "********"
        case .phone: return "********"
        }
    }
    func signuprRegisterPlaceholder() -> String {
        switch self {
        case .account: return "********"
        case .phone: return "********"
        }
    }
    func forgotAccountPlacehloder() -> String {
        switch self {
        case .account: return "...@mundo.com"
        case .phone: return ""
        }
    }
    func verifyPlaceholder() -> String {
        return "Enter the 6-digit code".localized
    }
    
    func signupSuccessTitles() -> SignupSuccessTitle {
        switch self {
        case .phone:
            return SignupSuccessTitle(title: "完善您的个人资料", doneButtonTitle: "立即修改", showAccount: true)
        case .account:
            return SignupSuccessTitle(title: "欢迎加入倍利 祝您畅玩倍利", doneButtonTitle: "开始投注", showAccount: false)
        }
    }
    
    struct SignupSuccessTitle {
        let title: String
        let doneButtonTitle: String
        let showAccount: Bool
    }
}
