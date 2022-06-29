//
//  SocketMessageDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/21/22.
//

import Foundation

struct SocketMessageDto: Codable{
    var type: String? = ""
    
}

struct SocketApprovalDoneDto: Codable{
    var type: String
    var payload: ApprovalPayloadDto
}

struct SocketTxCallBackDto: Codable{
    var type: String
    var payload: TXPayloadDto
}

