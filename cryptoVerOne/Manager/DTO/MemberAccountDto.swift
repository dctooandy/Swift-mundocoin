//
//  MemberAccountDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/27/22.
//

import Foundation
class MemberAccountDto {
    static var share: MemberAccountDto?
    
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
