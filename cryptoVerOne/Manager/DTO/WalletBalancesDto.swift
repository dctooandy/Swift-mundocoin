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
                Beans.walletServer.walletBalances().subscribe { [self] balancesDto in
                    share = balancesDto
                    subject.onNext(())
                } onError: { (error) in
                    subject.onError(error)
                }.disposed(by: disposeBag)
                return subject.asObservable()
            }
            var total : JSONValue
            var wallets : [WalletBalancesDto]?
}
class WalletBalancesDto :Codable {

    var id: String
    var createdDate: String
    var updatedDate: String
    var amount : JSONValue
    var address: String
    var currency: String
    var token: String?
    var chain: String?
    var persentValue: String?

    init(id: String = "", createdDate: String = "", updatedDate: String = "" , amount:JSONValue = JSONValue.int(0) ,address: String = "", currency: String = "", token: String = "", chain : String = "", persentValue : String = "") {
        self.id = id
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.amount = amount
        self.address = address
        self.currency = currency
        self.token = token
        self.chain = chain
        self.persentValue = persentValue
    }
}
