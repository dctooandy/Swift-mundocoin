//
//  AddressBookDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/8/22.
//

import Foundation
import Foundation
import RxSwift

class AddressBookDto :Codable {

    var coin: String = ""
    var address: String = ""
    var network: String = ""
    var name: String = ""
    var walletLabel: String = ""
    var isWhiteList:Bool = false

    init(coin: String = "", address: String = "", network: String = "" , name: String = "", walletLabel: String = "", isWhiteList: Bool = false) {
        self.coin = coin
        self.address = address
        self.network = network
        self.name = name
        self.walletLabel = walletLabel
        self.isWhiteList = isWhiteList
    }
}
