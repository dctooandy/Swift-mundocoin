//
//  LoginPostDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation

struct LoginPostDto {
    var account: String = ""
    var password: String = ""
    var loginMode: LoginMode
    let timestamp = Date.timestamp()
    let finger = KeychainManager.share.getFingerID()
    let currentShowMode : ShowMode
    var resetCode:String = ""
    var phoneCode: String = ""
    var phone: String = ""
    var rememberMeStatus: Bool = false
    init(account: String, password: String, loginMode: LoginMode , showMode : ShowMode , resetCode:String = "" , phoneCode : String? = "" , phone : String? = "" , rememberMeStatus : Bool = false) {
        self.account = account
        self.password = password
        self.loginMode = loginMode
        self.currentShowMode = showMode
        self.resetCode = resetCode
        self.phoneCode = phoneCode ?? ""
        self.phone = phone ?? ""
        self.rememberMeStatus = rememberMeStatus
    }
    var toVerifyAccountString: String {
        switch loginMode {
        case .emailPage:
            return account.hideEmailAccount()
        case .phonePage:
            return String(phone.hidePhoneAccount())
        }
    }
    var toAccountString: String {
        switch loginMode {
        case .emailPage:
            return account.localizedLowercase
        case .phonePage:
            return String(phone)
        }
    }
    var phoneWithoutCode: String
    {
        let index = phone.index(phone.startIndex, offsetBy: phoneCode.count)
        let mySubstring = phone[index...] // Hello
        return String(mySubstring)
    }
    var phoneCodeWithoutPhone: String
    {
        var currentCode = ""
        let mobileData = KeychainManager.share.getDefaultData()
        var codeArray:[String] = []
        for subData in mobileData
        {
            codeArray.append(subData.code)
        }
        for codeString in codeArray
        {
            if String(phone).contains(codeString)
            {
                currentCode = codeString
                break
            }
        }
        return currentCode
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


