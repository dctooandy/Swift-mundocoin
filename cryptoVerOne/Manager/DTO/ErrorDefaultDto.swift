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
    var httpStatus:String? = ""
    var code: String = ""
    var reason: String = ""
    var timestamp: Int = 0
    var errors: [ErrorsDetailDto] = [ErrorsDetailDto()]
  
    init(code: String = "", reason: String = "", timestamp : Int = 0,httpStatus : String = "",errors: [ErrorsDetailDto] = [ErrorsDetailDto()]) {
        self.code = code
        self.reason = reason
        self.timestamp = timestamp
        self.errors = errors
    }
}
struct ErrorsDetailDto :Codable{
    var field: String = ""
    var rejectValue: String = ""
    var reason:String = ""
    
    init(field: String = "", rejectValue: String = "", reason : String = "") {
        self.field = field
        self.rejectValue = rejectValue
        self.reason = reason
    }
}
