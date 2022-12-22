//
//  InfoDto.swift
//  cryptoVerOne
//
//  Created by BBk on 12/22/22.
//

import Foundation
import RxSwift
struct InfoDto :Codable {
    var network: String? = ""
    var currency: String? = ""
    var fee: Double? = 0.0
    var depositLimit: Int? = 0
    var withdrawLimit: Int? = 0
    init(network: String? = nil, currency: String? = nil, fee: Double? = nil, depositLimit: Int? = nil, withdrawLimit: Int? = nil) {
        self.network = network
        self.currency = currency
        self.fee = fee
        self.depositLimit = depositLimit
        self.withdrawLimit = withdrawLimit
    }
}
