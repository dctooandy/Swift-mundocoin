//
//  WalletBalancesDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/30/22.
//

import Foundation
import RxSwift
class WalletBalancesDto :Codable {

    var id: String
    var createdDate: String
    var updatedDate: String
    var amount : Int
    var address: String
    var currency: String
    var token: String

    init(id: String = "", createdDate: String = "", updatedDate: String = "" , amount:Int = 0 ,address: String = "", currency: String = "", token: String = "") {
        self.id = id
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.amount = amount
        self.address = address
        self.currency = currency
        self.token = token
    }
}
