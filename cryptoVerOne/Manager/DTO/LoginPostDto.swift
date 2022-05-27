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
    let id:Int?
    let token:String?
    var toJsonString: String {
        do {
            let jsonData = try self.jsonData()
            //            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            //                  guard let dictionary = json as? [String : Any] else {
            //                    return [:]
            //                  }
            //            return dictionary as Dictionary
            // Use dictionary
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
            }
            return jsonString
            //                  // Print jsonString
            //                  print(jsonString)
        } catch  {
            
        }
        return ""
    }
}

class LastLoginInDto: Codable {
    let area: String?
    let city: String?
    let country: String?
    let province: String?
    let telecom: String?
}


