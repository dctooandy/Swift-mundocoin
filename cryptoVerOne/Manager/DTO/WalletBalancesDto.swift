//
//  WalletBalancesDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/30/22.
//

import Foundation
import RxSwift
struct WalletAllBalancesDto :Codable {
    static var share:WalletAllBalancesDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<WalletAllBalancesDto?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update()
            }
    })
            static let disposeBag = DisposeBag()
            static private let subject = PublishSubject<WalletAllBalancesDto?>()
            static func update() -> Observable<()>{
                let subject = PublishSubject<Void>()
                Beans.walletServer.walletBalances().subscribe { [self](balancesDto) in
                    share = WalletAllBalancesDto()
                    share?.allBalances = balancesDto
                    
                    subject.onNext(())
                } onError: { (error) in
                    subject.onError(error)
                }.disposed(by: disposeBag)
                return subject.asObservable()
            }

    var allBalances : [WalletBalancesDto]? 
}
class WalletBalancesDto :Codable {

    var id: String
    var createdDate: String
    var updatedDate: String
    var amount : JSONValue
    var address: String
    var currency: String
//    var token: String?
    var persentValue: String?

    init(id: String = "", createdDate: String = "", updatedDate: String = "" , amount:JSONValue = JSONValue.int(0) ,address: String = "", currency: String = "", persentValue : String = "") {
        self.id = id
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.amount = amount
        self.address = address
        self.currency = currency
        self.persentValue = persentValue
//        self.token = token
    }
}
