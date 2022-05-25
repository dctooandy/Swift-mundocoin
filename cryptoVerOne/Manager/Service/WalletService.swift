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
    func walletAddress() -> Single<LoginDto?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestPost(
            path: ApiService.walletAddress.path,
            parameters: parameters,
            modify: false,
            resultType: LoginDto.self).map({
                return $0
            })
    }
    
}
