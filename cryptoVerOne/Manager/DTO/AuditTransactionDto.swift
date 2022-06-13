//
//  AuditTransactionDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//


import Foundation
import RxSwift
struct AuditTransactionDto :Codable {

    var userid: String = ""
    var crypto: String = ""
    var network: String = ""
    var withdrawAmount: String = ""
    var fee: String = ""
    var actualAmount: String = ""
    var address: String = ""
    var date: String = ""
    var beginDate: TimeInterval = 0
    var status: String = ""
    var comment: String = ""
    var txid:String = ""


//    init(size: Int = 0, content: [String] = [""], number: Int = 0 , first: Bool = false, last: Bool = false, numberOfElements: Int = 0, empty: Bool = false) {
//        self.size = size
//        self.content = content
//        self.number = number
//        self.first = first
//        self.last = last
//        self.numberOfElements = numberOfElements
//        self.empty = empty
//    }
}
