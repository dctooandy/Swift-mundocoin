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
}
