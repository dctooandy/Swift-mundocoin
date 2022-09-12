//
//  AddressBookDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/8/22.
//

import Foundation
import RxSwift

class AddressBookDto :Codable {

    var id:String = ""
    var createdDate: String = ""
    var updatedDate: String = ""
    var currency: String = ""
    var chain: String = ""
    var address: String = ""
    var name: String = ""
    var label: String = ""
    var enabled:Bool = false
    var network: String? = ""
    
    init(id: String = "",createdDate: String = "", updatedDate: String = "" , currency: String = "", chain: String = "", address: String = "" , name: String = "", label: String = "", enabled: Bool = false , network: String? = "") {
        self.id = id
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.currency = currency
        self.chain = chain
        self.address = address
        self.name = name
        self.label = label
        self.enabled = enabled
        self.network = network
    }
}
