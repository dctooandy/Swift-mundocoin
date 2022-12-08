//
//  VerificationCodeDto.swift
//  cryptoVerOne
//
//  Created by BBk on 12/8/22.
//

import Foundation

class VerificationCodeDto:Codable {
    let id:String
    let code:String
    init(id : String = "" , code:String = "") {
        self.id = id
        self.code = code
    }
}
