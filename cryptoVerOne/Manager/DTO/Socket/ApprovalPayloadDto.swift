//
//  ApprovalPayloadDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/29/22.
//

import Foundation

struct ApprovalPayloadDto : Codable {
    var id : String? = ""
    var createdDate : TimeInterval? = 0.0
    var updatedDate : TimeInterval? = 0.0
    var type : String? = ""
    var state : String? = ""
//    var chain : [ChainSocketDto]? = []
//    var transaction : ContentSocketDto? = ContentSocketDto()
//    var issuer : IssuerSocketDto? = IssuerSocketDto()
}
