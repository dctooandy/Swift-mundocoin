//
//  WalletTransactionDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//

import Foundation
import RxSwift
struct WalletTransactionDto :Codable {

    let size: Int
    let content: [ContentDto]
    let number: Int
    let sort : SortDto
    let pageable: PageableDto
    let first: Bool
    let last: Bool
    let numberOfElements:Int
    let empty:Bool

    init(size: Int = 0, content: [ContentDto] = [], number: Int = 0 , sort:SortDto = SortDto() ,pageable: PageableDto = PageableDto(), first: Bool = false, last: Bool = false, numberOfElements: Int = 0, empty: Bool = false) {
        self.size = size
        self.content = content
        self.number = number
        self.sort = sort
        self.pageable = pageable
        self.first = first
        self.last = last
        self.numberOfElements = numberOfElements
        self.empty = empty
    }
}

struct SortDto :Codable
{
    var empty:Bool = false
    var sorted:Bool = false
    var unsorted:Bool = false
}
struct PageableDto :Codable
{
    var offset :Int = 0
    var sort :SortDto = SortDto()
    var pageNumber:Int = 0
    var pageSize:Int = 0
    var paged:Bool = false
    var unpaged:Bool = false
}

struct ContentDto : Codable
{
    var date : String = ""
    var currency : String = ""
    var amount : String = ""
    var status : String = ""
}

