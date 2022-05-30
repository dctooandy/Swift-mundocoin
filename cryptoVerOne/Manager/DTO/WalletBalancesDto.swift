//
//  WalletBalancesDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/30/22.
//

import Foundation
import RxSwift
struct WalletBalancesDto :Codable {

    let id: String
    let createdDate: String
    let updatedDate: String
    let amount : Int
    let address: String
    let currency: String
    let token: String

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
