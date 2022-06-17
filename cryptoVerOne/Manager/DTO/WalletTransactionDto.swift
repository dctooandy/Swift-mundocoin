//
//  WalletTransactionDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//

import Foundation
import RxSwift
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
    var size:String = "10"
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
    var date : TimeInterval
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

    var amount : Int? = 0    
    var id : String = ""
    var createdDate : String = ""
    var updatedDate : String = ""
    var type : String = ""
    var orderId : String = ""
    var currency : String = ""
    var txId : String? = ""
    var blockHeight : String? = ""
    var fees : Int? = 0
    var broadcastTimestamp : TimeInterval? = 0
    var chainTimestamp : TimeInterval? = 0
    var fromAddress : String = ""
    var toAddress : String = ""
    var associatedWalletId : Int = 0
    var state : String = ""
    var confirmBlocks : Int = 0
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

}
