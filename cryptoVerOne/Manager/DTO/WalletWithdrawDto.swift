//
//  WalletWithdrawDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/16/22.
//

import Foundation
import RxSwift
struct WalletWithdrawDto :Codable {
    
}

//{
//
//  "id": "8ed18f57-d0e5-4848-99d5-64d017225276",
//  "createdDate": "2022-06-16T10:06:24.307+00:00",
//  "updatedDate": "2022-06-16T10:06:24.307+00:00",
//  "type": "WITHDRAW",
//  "state": "PENDING",
//  "chain": [
//    {
//      "id": "6961cc0e-cca9-4cde-9d99-3b67a84e49b2",
//      "createdDate": "2022-06-16T10:06:24.308+00:00",
//      "updatedDate": "2022-06-16T10:06:24.308+00:00",
//      "state": "PENDING",
//      "memo": "AUTO-REQUESTING",
//      "approver": {
//        "id": "26588240-875d-4c02-ab86-d31a16934560",
//        "createdDate": "2022-01-01T00:00:00.000+00:00",
//        "updatedDate": "2022-06-16T09:50:01.600+00:00",
//        "name": "admin",
//        "email": "admin@mundocoin.com",
//        "role": "SUPER_ADMIN",
//        "lastLoginDate": "2022-06-16T09:50:01.599972"
//      }
//    }
//  ],
//  "transaction": {
//    "id": "700d8f7f-a091-461a-a97d-8c28edf9943c",
//    "createdDate": "2022-06-16T10:06:24.305+00:00",
//    "updatedDate": "2022-06-16T10:06:24.305+00:00",
//    "type": "WITHDRAW",
//    "orderId": "7293781855",
//    "currency": "USDT",
//    "txId": null,
//    "blockHeight": null,
//    "amount": 1,
//    "fees": null,
//    "broadcastTimestamp": null,
//    "chainTimestamp": null,
//    "fromAddress": "string",
//    "toAddress": "string",
//    "associatedWalletId": 0,
//    "state": "PENDING",
//    "confirmBlocks": 0,
//    "processingState": "INIT",
//    "decimal": 0,
//    "currencyBip44": 0,
//    "tokenAddress": null,
//    "memo": null,
//    "errorReason": null,
//    "amlScreenPass": null,
//    "feeDecimal": null,
//    "tindex": null,
//    "voutIndex": null
//  },
//  "issuer": {
//    "id": "bb6c4204-935d-42b6-98b9-4fa98b5a35a7",
//    "createdDate": "2022-05-27T08:20:49.913+00:00",
//    "updatedDate": "2022-06-16T01:57:08.883+00:00",
//    "email": "andy07@gmail.com",
//    "phone": null,
//    "registrationCode": "123123",
//    "firstName": null,
//    "middleName": null,
//    "lastName": null,
//    "status": "ACTIVATED",
//    "roles": "CUSTOMER",
//    "registrationIP": "125.229.69.187",
//    "lastLoginIP": "101.9.203.213",
//    "lastLoginDate": null,
//    "isPhoneRegistry": false,
//    "isEmailRegistry": true
//  }
