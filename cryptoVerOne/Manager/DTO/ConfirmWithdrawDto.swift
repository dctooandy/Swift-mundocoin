//
//  ConfirmWithdrawDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/19.
//

import Foundation
class ConfirmWithdrawDto:Codable {
    let totalAmount:String
    let tether:String
    let network:String
    let fee:String
    let address:String
    init(totalAmount : String = "" , tether:String = "", network:String = "", fee:String = "", address:String = "") {
        self.totalAmount = totalAmount
        self.tether = tether
        self.network = network
        self.fee = fee
        self.address = address
    }
    
}
