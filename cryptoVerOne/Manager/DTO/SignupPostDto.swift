//
//  SignupPostDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation

struct SignupPostDto {
    
    var account: String
    var password: String
    var phoneCode: String = ""
    var phone: String = ""
    let registration:String
    let signupMode: LoginMode
    let timestamp = Date.timestamp()
    let finger = KeychainManager.share.getFingerID()
    
    init(account: String, password: String, registration : String,signupMode: LoginMode ,phoneCode :String = "" , phone : String = "") {
        self.account = account
        self.password = password
        self.registration = registration
        self.signupMode = signupMode
        self.phoneCode = phoneCode
        self.phone = phone
    }
    var toVerifyAccountString: String {
        switch signupMode {
        case .emailPage:
            return account.hideEmailAccount()
        case .phonePage:
            return String(phone.hidePhoneAccount())
        }
    }
    var toAccountString: String {
        switch signupMode {
        case .emailPage:
            return account
        case .phonePage:
            return String(phone)
        }
    }
}

class SignupDto: Codable {
    let account: String?
    let password: String?
    init(account: String, password: String) {
        self.account = account
        self.password = password
    }
}

