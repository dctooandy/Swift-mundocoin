//
//  DetailDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/20.
//

import Foundation
class DetailDto {
    let defailType:DetailType
    let tether:String
    let network:String
    let confirmations:String
    let fee:String
    let date:String
    let address:String
    let txid:String
    let amount:String
    
    init(defailType : DetailType = .done ,amount:String = "", tether:String = "", network:String = "",confirmations:String = "",fee:String = "", date:String = "", address:String = "" , txid:String = "") {
        self.defailType = defailType
        self.amount = amount
        self.tether = tether
        self.network = network
        self.confirmations = confirmations
        self.fee = fee
        self.date = date
        self.address = address
        self.txid = txid
    }
}
