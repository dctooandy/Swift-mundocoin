//
//  AddressbookDeleteDto.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/9/12.
//

import Foundation
import RxSwift

class AddressbookDeleteDto :Codable {

    var code: String = ""

    init(code: String = "") {
        self.code = code
    }
}
