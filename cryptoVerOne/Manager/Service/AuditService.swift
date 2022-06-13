//
//  AuditService.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//


import Foundation
import Foundation
import RxCocoa
import RxSwift
import Alamofire

class AuditService {
    func auditTransactions() -> Single<[AuditTransactionDto]?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestGet(
            path: ApiService.walletAddress.path,
            parameters: parameters,
            modify: false,
            resultType: [AuditTransactionDto].self).map({
                return $0
            })
    }
 
    func walletTransactions(currency:String = "" , stats : String = "", beginDate:TimeInterval = 0 , endDate:TimeInterval = 0 , pageable :String = "") -> Single<WalletTransactionDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["currency"] = currency
        parameters["stats"] = stats
        parameters["beginDate"] = beginDate
        parameters["endDate"] = endDate
        parameters["pageable"] = pageable
        
        
        return Beans.requestServer.singleRequestGet(
            path: ApiService.walletTransactions.path,
            parameters: parameters,
            modify: false,
            resultType: WalletTransactionDto.self).map({
                return $0
            })
    }
}
