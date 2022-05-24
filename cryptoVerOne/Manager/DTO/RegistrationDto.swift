//
//  RegistrationDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
struct RegistrationDto :Codable{
    var createdDate : String = ""
    var email : String = ""
    var firstName : String?
    var id : String = ""
    var isEmailRegistry : JSONValue
    var isPhoneRegistry : JSONValue
    var lastLoginDate : String?
    var lastLoginIP : String?
    var lastName : String?
    var middleName : String?
    var phone : String?
    var registrationCode : String = ""
    var registrationIP : String = ""
    var roles : String = ""
    var status : String = ""
    var updatedDate : String = ""
    var wallet : String?
    
   
//    init(account: String, password: String, loginMode: LoginMode , showMode : ShowMode) {
//        self.account = account
//        self.password = password
//        self.loginMode = loginMode
//        self.currentShowMode = showMode
//    }
}
