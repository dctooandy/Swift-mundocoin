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
    let date:String
    let address:String
    let txid:String
    init(defailType : DetailType = .done , tether:String = "", network:String = "", date:String = "", address:String = "" , txid:String = "") {
        self.defailType = defailType
        self.tether = tether
        self.network = network
        self.date = date
        self.address = address
        self.txid = txid
    }
}
