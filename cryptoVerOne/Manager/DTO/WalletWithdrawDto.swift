//
//  WalletWithdrawDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/16/22.
//

import Foundation
import RxSwift
import SocketIO
struct WalletWithdrawDto :Codable {
    var id : String? = ""
    var createdDate : String? = ""
    var updatedDate : String? = ""
    var type : String? = ""
    var state : String? = ""
    var chain : [ChainDto]? = []
    var transaction : ContentDto? = ContentDto()
    var issuer : IssuerDto? = IssuerDto()
    
    func socketRepresentation() -> SocketData {
        return ["id": id
                , "createdDate": createdDate
                , "updatedDate": updatedDate
                , "type": type
                , "state": state
                , "chain": chain
                , "transaction": transaction
                , "issuer": issuer]
    }
    var detailType:DetailType {
        if self.state == "PENDING"
        {
            return .pending
        }else if state == "FAILED"
        {
            return.failed
        }else if state == "PROCESSING"
        {
            return .processing
        }else
        {
            return .done
        }
    }
    var createdDateString : String
    {
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMMM dd, yyyy HH:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let frontTime = createdDate!.components(separatedBy: "T").first!
        let subTime = createdDate!.components(separatedBy: "T").last!
        let subSubtime = subTime.components(separatedBy: "+").first!
        let aftertime = subSubtime.components(separatedBy: ".").first!
        let totalTime = "\(frontTime) \(aftertime)"
        if let dateFromString = dateFormatter.date(from:totalTime ) {
            return newDateFormatter.string(from: dateFromString)
        }else
        {
            return createdDate ?? ""
        }
    }

}
struct ChainDto:Codable {
    var id : String = ""
    var createdDate : String = ""
    var updatedDate : String = ""
    var state : String = ""
    var memo : String = ""
    var approver : ApproverDto = ApproverDto()
}
struct ChainSocketDto:Codable {
    var id : String = ""
    var createdDate : TimeInterval = 0
    var updatedDate : TimeInterval = 0
    var state : String = ""
    var memo : String = ""
    var approver : ApproverSocketDto = ApproverSocketDto()
}
struct ApproverDto:Codable {
    var id : String = ""
    var createdDate : String = ""
    var updatedDate : String = ""
    var name : String = ""
    var email : String = ""
    var role : String = ""
    var lastLoginDate : String = ""
}
struct ApproverSocketDto:Codable {
    var id : String = ""
    var createdDate : TimeInterval = 0
    var updatedDate : TimeInterval = 0
    var name : String = ""
    var email : String = ""
    var role : String = ""
    var lastLoginDate : [Int] = []
}
struct IssuerDto : Codable {
    var id : String = ""
    var createdDate : String = ""
    var updatedDate : String = ""
    var email : String = ""
    var phone : String? = ""
    var registrationCode : String = ""
    var firstName : String? = ""
    var middleName : String? = ""
    var lastName : String? = ""
    var status : String = ""
    var roles : String = ""
    var registrationIP : String = ""
    var lastLoginIP : String = ""
    var lastLoginDate : String? = ""
    var isPhoneRegistry : Bool = false
    var isEmailRegistry : Bool = false
}
struct IssuerSocketDto : Codable {
    var id : String = ""
    var createdDate : TimeInterval = 0
    var updatedDate : TimeInterval = 0
    var email : String = ""
    var phone : String? = ""
    var registrationCode : String = ""
    var firstName : String? = ""
    var middleName : String? = ""
    var lastName : String? = ""
    var status : String = ""
    var roles : String = ""
    var registrationIP : String = ""
    var lastLoginIP : String = ""
    var lastLoginDate : [Int]? = []
    var isPhoneRegistry : Bool = false
    var isEmailRegistry : Bool = false
}
