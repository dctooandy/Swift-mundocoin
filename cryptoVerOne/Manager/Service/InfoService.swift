//
//  InfoService.swift
//  cryptoVerOne
//
//  Created by BBk on 12/22/22.
//

import Foundation
import Foundation
import RxCocoa
import RxSwift
import Alamofire

class InfoService {
    func fetchCurrencySettings() -> Single<[InfoDto]?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestGet(
            path: ApiService.currencySettings.path,
            parameters: parameters,
            modify: false,
            resultType: [InfoDto].self).map({
                return $0
            })
    }
    
}
