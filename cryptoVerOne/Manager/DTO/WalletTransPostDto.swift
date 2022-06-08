//
//  WalletTransPostDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//

import Foundation
import RxSwift
struct WalletTransPostDto :Codable {

    var currency: String = ""
    var stats: String = ""
    var beginDate: TimeInterval = 0
    var endDate: TimeInterval = 0
    var pageable: String = ""


//    init(size: Int = 0, content: [String] = [""], number: Int = 0 , first: Bool = false, last: Bool = false, numberOfElements: Int = 0, empty: Bool = false) {
//        self.size = size
//        self.content = content
//        self.number = number
//        self.first = first
//        self.last = last
//        self.numberOfElements = numberOfElements
//        self.empty = empty
//    }
}
