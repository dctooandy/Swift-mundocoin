//
//  WalletService.swift
//  cryptoVerOne
//
//  Created by BBk on 5/25/22.
//

import Foundation
import Foundation
import RxCocoa
import RxSwift
import Alamofire

class WalletService {
    func walletAddress() -> Single<WalletAddressDto?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestGet(
            path: ApiService.walletAddress.path,
            parameters: parameters,
            modify: false,
            resultType: WalletAddressDto.self).map({
                return $0
            })
    }
    func walletBalances() -> Single<[WalletBalancesDto]?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestGet(
            path: ApiService.walletBalances.path,
            parameters: parameters,
            modify: false,
            resultType: [WalletBalancesDto].self).map({
                return $0
            })
    }
    func walletTransactions(currency:String = "ALL" , stats : String = "ALL", beginDate:TimeInterval = 0 , endDate:TimeInterval = 0 , pageable :PagePostDto = PagePostDto()) -> Single<WalletTransactionDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["currency"] = currency
        parameters["stats"] = stats
        parameters["beginDate"] = beginDate
        parameters["endDate"] = endDate
        parameters["page"] = pageable.page
        parameters["size"] = pageable.size
//        parameters["pageable"] = pageable.toJsonString
        
        
        return Beans.requestServer.singleRequestGet(
            path: ApiService.walletTransactions.path,
            parameters: parameters,
            modify: false,
            resultType: WalletTransactionDto.self).map({
                return $0
            })
    }
    
    
    func walletWithdraw(amount:String , fArrdess:String , tAddress:String) -> Single<WalletWithdrawDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["amount"] = amount
        parameters["fromAddress"] = fArrdess
        parameters["toAddress"] = tAddress
        
        return Beans.requestServer.singleRequestPost(
            path: ApiService.walletWithdraw.path,
            parameters: parameters,
            modify: false,
            resultType: WalletWithdrawDto.self).map({
                return $0
            })
    }
}
