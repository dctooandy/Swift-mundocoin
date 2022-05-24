//
//  SignupPostDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation

struct SignupPostDto {
    
    let account: String
    let password: String
    let registration:String
    let signupMode: LoginMode
    let timestamp = Date.timestamp()
    let finger = KeychainManager.share.getFingerID()
    
    init(account: String, password: String, registration : String,signupMode: LoginMode) {
        self.account = account
        self.password = password
        self.registration = registration
        self.signupMode = signupMode
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

