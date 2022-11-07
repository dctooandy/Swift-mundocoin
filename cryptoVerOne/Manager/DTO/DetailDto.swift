//
//  DetailDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/20.
//

import Foundation
class DetailDto {
    let detailType:DetailType
    let tether:String
    let network:String
    let confirmations:String
    let fee:String
    let date:String
    var address:String
    let fromAddress:String
    let txid:String
    let amount:String
    let id:String
    var orderId : String
    var confirmBlocks : Int
    var showMode:TransactionShowMode?
    var type: String
    init(detailType : DetailType = .done ,amount:String = "", tether:String = "", network:String = "",confirmations:String = "",fee:String = "", date:String = "", address:String = "" ,fromAddress:String = "", txid:String = "" ,id:String = "" , orderId:String = "" , confirmBlocks : Int = 0 , showMode:TransactionShowMode = .deposits , type:String = "") {
        self.detailType = detailType
        self.amount = amount
        self.tether = tether
        self.network = network
        self.confirmations = confirmations
        self.fee = fee
        self.date = date
        self.address = address
        self.fromAddress = fromAddress
        self.txid = txid
        self.id = id
        self.orderId = orderId
        self.confirmBlocks = confirmBlocks
        self.showMode = showMode
        self.type = type
    }
}
