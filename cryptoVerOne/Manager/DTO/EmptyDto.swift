//
//  EmptyDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/24/22.
//

import Foundation
class EmptyDto: Codable {
    
    let size: Int
//    let content: [ContentDto]
    let number: Int
    let sort : SortDto
    let pageable: PageableDto
    let first: Bool
    let last: Bool
    let numberOfElements:Int
    let empty:Bool
}

