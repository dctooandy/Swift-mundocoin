//
//  SelectCryptoDto.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/30.
//

import Foundation
class SelectCryptoDto :Codable {

    var cryptos : [SelectCryptoDetailDto] = [SelectCryptoDetailDto()]
    init(cryptos: [SelectCryptoDetailDto] = [SelectCryptoDetailDto()]) {
        self.cryptos = cryptos
    }
}
class SelectCryptoDetailDto : Codable {
    var cryptoName: String = ""
    var cryptoIconName: String = ""
    var cryptoNetworkName: String = ""

    init(cryptoName: String = "",cryptoIconName: String = "",cryptoNetworkName: String = "") {
        self.cryptoName = cryptoName
        self.cryptoIconName = cryptoIconName
        self.cryptoNetworkName = cryptoNetworkName
    }
}
