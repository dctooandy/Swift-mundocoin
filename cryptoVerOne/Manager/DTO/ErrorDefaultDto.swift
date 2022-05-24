//
//  ErrorDefaultDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
struct ErrorDefaultDto :Codable,Equatable{
    static func == (lhs: ErrorDefaultDto, rhs: ErrorDefaultDto) -> Bool {
        return lhs.code == rhs.code
    }
    let code: String?
    let reason: String?
    let timestamp:String?
    let errors: ErrorsDetailDto?
  
    init(code: String = "", reason: String = "", timestamp : String = "",errors: ErrorsDetailDto = ErrorsDetailDto()) {
        self.code = code
        self.reason = reason
        self.timestamp = timestamp
        self.errors = errors
    }
}
struct ErrorsDetailDto :Codable{
    let field: String
    let rejectValue: String
    let reason:String
    
    init(field: String = "", rejectValue: String = "", reason : String = "") {
        self.field = field
        self.rejectValue = rejectValue
        self.reason = reason
    }
}
