//
//  UserAddressDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/16.
//

import Foundation
struct UserAddressDto {
    
    let accountName: String
    let address: String
    let protocolType: String
    let timestamp = Date.timestamp()

    init(accountName: String, address: String, protocolType: String) {
        self.accountName = accountName
        self.address = address
        self.protocolType = protocolType
    }
}
