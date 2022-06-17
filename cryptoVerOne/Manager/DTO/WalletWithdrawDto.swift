//
//  WalletWithdrawDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/16/22.
//

import Foundation
import RxSwift
struct WalletWithdrawDto :Codable {
    var id : String = ""
    var createdDate : String = ""
    var updatedDate : String = ""
    var type : String = ""
    var state : String = ""
    var chain : [ChainDto] = []
    var transaction : ContentDto = ContentDto()
    var issuer : IssuerDto = IssuerDto()
    
    var defailType:DetailType {
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
        let frontTime = createdDate.components(separatedBy: "T").first!
        let subTime = createdDate.components(separatedBy: "T").last!
        let subSubtime = subTime.components(separatedBy: "+").first!
        let aftertime = subSubtime.components(separatedBy: ".").first!
        let totalTime = "\(frontTime) \(aftertime)"
        if let dateFromString = dateFormatter.date(from:totalTime ) {
            return newDateFormatter.string(from: dateFromString)
        }else
        {
            return createdDate
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
struct ApproverDto:Codable {
    var id : String = ""
    var createdDate : String = ""
    var updatedDate : String = ""
    var name : String = ""
    var email : String = ""
    var role : String = ""
    var lastLoginDate : String = ""
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
