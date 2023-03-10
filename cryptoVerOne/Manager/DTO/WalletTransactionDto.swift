//
//  WalletTransactionDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//

import Foundation
import RxSwift
import UIKit
struct WalletTransactionDto :Codable {

    let size: Int
    let content: [ContentDto]
    let number: Int
    let sort : SortDto
    let pageable: PageableDto
    let first: Bool
    let last: Bool
    let numberOfElements:Int
    let empty:Bool

    init(size: Int = 0, content: [ContentDto] = [], number: Int = 0 , sort:SortDto = SortDto() ,pageable: PageableDto = PageableDto(), first: Bool = false, last: Bool = false, numberOfElements: Int = 0, empty: Bool = false) {
        self.size = size
        self.content = content
        self.number = number
        self.sort = sort
        self.pageable = pageable
        self.first = first
        self.last = last
        self.numberOfElements = numberOfElements
        self.empty = empty
    }
}

struct SortDto :Codable
{
    var empty:Bool = false
    var sorted:Bool = false
    var unsorted:Bool = false
}
struct PagePostDto : Codable
{
    var size:String = "20"
    var page:String = "0"
    var toJsonString: String {
        do {
            let jsonData = try self.jsonData()
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
            }
            return jsonString
        } catch  {
        }
        return ""
    }
}
struct PageableDto :Codable
{
    var offset :Int = 0
    var sort :SortDto = SortDto()
    var pageNumber:Int = 0
    var pageSize:Int = 20
    var paged:Bool = false
    var unpaged:Bool = false
    
    var toJsonString: String {
        do {
            let jsonData = try self.jsonData()
            //            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            //                  guard let dictionary = json as? [String : Any] else {
            //                    return [:]
            //                  }
            //            return dictionary as Dictionary
            // Use dictionary
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
            }
            return jsonString
            //                  // Print jsonString
            //                  print(jsonString)
        } catch  {
            
        }
        return ""
    }
}
struct ContentDto : Codable
{
    var showTitleString:String
    {
        switch self.type {
        case "DEPOSIT":
            return "Deposit Details".localized
        case "WITHDRAW":
            return "Withdrawal Details".localized
        default: return ""
        }
    }
    var createdDateTimeInterval : TimeInterval
    {
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
            return dateFromString.timeIntervalSince1970
        }else
        {
            return 0.0
        }
    }
    var updatedDateTimeInterval : TimeInterval
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let frontTime = updatedDate.components(separatedBy: "T").first!
        let subTime = updatedDate.components(separatedBy: "T").last!
        let subSubtime = subTime.components(separatedBy: "+").first!
        let aftertime = subSubtime.components(separatedBy: ".").first!
        let totalTime = "\(frontTime) \(aftertime)"
        if let dateFromString = dateFormatter.date(from:totalTime ) {
            return dateFromString.timeIntervalSince1970
        }else
        {
            return 0.0
        }
    }
    var detailType:DetailType {
        if self.state == "PENDING" || self.state == "Pending" || self.processingState == "PENDING"
        {
            return .pending
        }else if state == "TRANSACTION_FAILED" ||
                    self.state == "FAILED" ||
                    self.state == "Failed" ||
                    self.processingState == "FAILED"
        {
            //????????????Inner
            return .failed
//            return .innerFailed
        }else if state == "PROCESSING" || state == "Processing"
        {
            return .processing
        }else
        {
            //????????????Inner
            return .done
//            return .innerDone
        }
    }
    var stateValue:String
    {
        switch self.detailType
        {
        case .done,.innerDone:
            return "COMPLETE"
        case .pending:
            return "PENDING"
        case .failed,.innerFailed:
            return "FAILED"
        case .processing:
            return "PROCESSING"
        }
    }
    var stateColor:UIColor
    {
        switch self.detailType
        {
        case .done,.innerDone:
            return UIColor(rgb: 0x47CD6C)
        case .pending:
            return UIColor(rgb: 0xF50D0D)
        case .failed,.innerFailed:
            return UIColor(rgb: 0xF50D0D)
        case .processing:
            return UIColor(rgb: 0xF50D0D)
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
    var createdAuditDateString : String
    {
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
    var updatedDateString : String
    {
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMMM dd, yyyy HH:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let frontTime = updatedDate.components(separatedBy: "T").first!
        let subTime = updatedDate.components(separatedBy: "T").last!
        let subSubtime = subTime.components(separatedBy: "+").first!
        let aftertime = subSubtime.components(separatedBy: ".").first!
        let totalTime = "\(frontTime) \(aftertime)"
        if let dateFromString = dateFormatter.date(from:totalTime ) {
            return newDateFormatter.string(from: dateFromString)
        }else
        {
            return updatedDate
        }
    }
    var walletAmountIntWithDecimal : JSONValue?
    {
        var difValue = 0.0
        if stateValue == "FAILED" || stateValue == "PENDING" || blockHeight == nil
        {
            if blockHeight != nil
            {
                // ???????????????fee,??????amount??????
//                difValue = serviceFee ?? 0.0
            }else
            {
                difValue = 0.0
            }
        }
        if let amountDoubleValue = amount?.doubleValue
        {
//            let doubleValue = amountDoubleValue / pow(10, Double(decimal ?? 0))
            let doubleValue = amountDoubleValue
            return JSONValue.double(doubleValue + difValue)
        }else if let intValue = amount?.intValue
        {
//            let doubleValue = Double(intValue) / pow(10, Double(decimal ?? 0))
            let doubleValue = Double(intValue)
            return JSONValue.double(doubleValue + difValue)
        }else 
        {
            return JSONValue.double(0.00)
        }
    }
    var walletDepositAmountIntWithDecimal : JSONValue?
    {
        if let amountDoubleValue = amount?.doubleValue
        {
//            let doubleValue = amountDoubleValue / pow(10, Double(decimal ?? 0))
            let doubleValue = amountDoubleValue
            return JSONValue.double(doubleValue)
        }else if let intValue = amount?.intValue
        {
//            let doubleValue = Double(intValue) / pow(10, Double(decimal ?? 0))
            let doubleValue = Double(intValue)
            return JSONValue.double(doubleValue)
        }else
        {
            return JSONValue.double(0.00)
        }
    }
    var amount : JSONValue? = JSONValue.int(0)
    var rawAmount : JSONValue? = JSONValue.int(0)
    var id : String = ""
    var createdDate : String = ""
    var updatedDate : String = ""
    var type : String = ""
    var orderId : String = ""
    var currency : String = ""
    var txId : String? = ""
    var blockHeight : Int? = 0
    var fees : Int? = 0
    var broadcastTimestamp : String? = ""
    var chainTimestamp : String? = ""
    var fromAddress : String = ""
    var toAddress : String = ""
    var associatedWalletId : JSONValue? = JSONValue.int(0)
    var state : String = ""
    var confirmBlocks : Int? = 0
    var processingState : String = ""
    var decimal : Int? = 0
    var currencyBip44 : Int? = 0
    var tokenAddress : String? = ""
    var memo : String? = ""
    var errorReason : String? = ""
    var amlScreenPass : String? = ""
    var feeDecimal : Int? = 0
    var tindex : String? = ""
    var voutIndex : String? = ""
    var customer : TransCustomerDto? = TransCustomerDto()
    // ?????? Fee
    var actualAmount: Double? = 0.0
    var serviceFee: Double? = 0.0
}
struct ContentSocketDto : Codable
{
    var amount : JSONValue? = JSONValue.int(0)
    var rawAmount : JSONValue? = JSONValue.int(0)
    var id : String = ""
    var createdDate : TimeInterval = 0
    var updatedDate : TimeInterval = 0
    var type : String = ""
    var orderId : String = ""
    var currency : String = ""
    var txId : String? = ""
    var blockHeight : Int? = 0
    var fees : Int? = 0
    var broadcastTimestamp : String? = ""
    var chainTimestamp : String? = ""
    var fromAddress : String = ""
    var toAddress : String = ""
    var associatedWalletId : JSONValue? = JSONValue.int(0)
    var state : String = ""
    var confirmBlocks : Int? = 0
    var processingState : String = ""
    var decimal : Int = 0
    var currencyBip44 : Int = 0
    var tokenAddress : String? = ""
    var memo : String? = ""
    var errorReason : String? = ""
    var amlScreenPass : String? = ""
    var feeDecimal : Int? = 0
    var tindex : String? = ""
    var voutIndex : String? = ""
    // ?????? Fee
    var actualAmount: Double? = 0.0
    var serviceFee: Double? = 0.0
}
