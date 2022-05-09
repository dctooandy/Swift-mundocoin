//
//  LoginPostDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation

struct LoginPostDto {
    let account: String
    let password: String
    let loginMode: LoginMode
    let timestamp = Date.timestamp()
    let finger = KeychainManager.share.getFingerID()
    let currentShowMode : ShowMode
    init(account: String, password: String, loginMode: LoginMode , showMode : ShowMode) {
        self.account = account
        self.password = password
        self.loginMode = loginMode
        self.currentShowMode = showMode
    }
}

class LoginDto: Codable {
    let account: String?
    let accountChanged: Bool?
    let email: String?
    let lastLoginAt: String?
    let lastLoginIn: LastLoginInDto?
    let phone: String?
}

class LastLoginInDto: Codable {
    let area: String?
    let city: String?
    let country: String?
    let province: String?
    let telecom: String?
}

class MemberAccount {
    static var share: MemberAccount?
    
    init(account: String, password: String, loginMode: LoginMode, phone: String? = nil) {
        self.account = account
        self.password = password
        self.loginMode = loginMode
        self.phone = phone
    }
    
    let account: String
    var password: String
    let loginMode: LoginMode
    var phone: String?
}
