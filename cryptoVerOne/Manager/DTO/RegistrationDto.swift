//
//  RegistrationDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
struct RegistrationDto :Codable{
    let createdDate : JSONValue?
    let email : JSONValue?
    let firstName : JSONValue?
    let id : JSONValue?
    let isEmailRegistry : JSONValue?
    let isPhoneRegistry : JSONValue?
    let lastLoginDate : JSONValue?
    let lastLoginIP : JSONValue?
    let lastName : JSONValue?
    let middleName : JSONValue?
    let phone : JSONValue?
    let registrationCode : JSONValue?
    let registrationIP : JSONValue?
    let roles : JSONValue?
    let status : JSONValue?
    let updatedDate : JSONValue?
    let wallet : JSONValue?
    
   
//    init(account: String, password: String, loginMode: LoginMode , showMode : ShowMode) {
//        self.account = account
//        self.password = password
//        self.loginMode = loginMode
//        self.currentShowMode = showMode
//    }
}
