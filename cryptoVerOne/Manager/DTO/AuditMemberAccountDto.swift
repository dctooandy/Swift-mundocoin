//
//  AuditMemberAccountDto.swift
//  cryptoVerOne
//
//  Created by Andy on 2023/1/16.
//

import Foundation
class AuditMemberAccountDto {
    static var share: AuditMemberAccountDto?
    var account: String = ""
    var email:String = ""
    
    init(account : String = "",
         email : String = "") {
        self.account = account
        self.email = email
    }
}
