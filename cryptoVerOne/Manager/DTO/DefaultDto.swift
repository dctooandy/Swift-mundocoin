//
//  DefaultDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
class DefaultDto: Codable {
    let code:Int?
    let msg:String?
    let info:[String]?
    
    let message:String?
    let ttl:Int?
    
    init(code:Int = 0,
         msg:String = "",
         info:[String] = [""],
         message:String = "",
         ttl:Int = 0)
    {
        self.code = code
        self.msg = msg
        self.info = info
        self.message = message
        self.ttl = ttl
    }
}
