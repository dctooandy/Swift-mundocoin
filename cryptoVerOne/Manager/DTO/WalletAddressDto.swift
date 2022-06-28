//
//  WalletAddressDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/26/22.
//

import Foundation
import RxSwift
struct WalletAddressDto :Codable {
    static var share:WalletAddressDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<WalletAddressDto?> = subject
        .do(onNext: { value in
            if share == nil {
                if UserStatus.share.isLogin == true {
                    _ = update(done: {
                        Log.v("完成")
                    })
                }
            }
        },onError: { error in
            Log.e("有錯誤")
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<WalletAddressDto?>(value: nil)
    static func update(done: @escaping () -> Void) -> Observable<()>{
        let subject = PublishSubject<Void>()
        
        Beans.walletServer.walletAddress().subscribe { [self](walletDto) in
            share = walletDto
            _ = LoadingViewController.dismiss()
            done()
            subject.onNext(())
        } onError: { [self](error) in
            _ = LoadingViewController.dismiss()
            subject.onError(error)
        }.disposed(by: disposeBag)

        return subject.asObservable()
    }
    let id: String
    let createdDate: String
    let updatedDate: String
    let amount : Int
    let address: String
    let currency: String
    let token: String?
    let customer : [WalletAddressCustomerDto]?

    init(id: String = "", createdDate: String = "", updatedDate: String = "" , amount:Int = 0 ,address: String = "", currency: String = "", token: String = "",customer : [WalletAddressCustomerDto] = [WalletAddressCustomerDto()]) {
        self.id = id
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.amount = amount
        self.address = address
        self.currency = currency
        self.token = token
        self.customer = customer
    }
}
struct WalletAddressCustomerDto :Codable{

    let id: String
    let createdDate: String
    let updatedDate: String
    let email : String
    let phone: String
    let registrationCode: String
    let firstName: String
    let middleName: String
    let lastName: String
    let status: String
    let roles: String
    let registrationIP: String
    let lastLoginIP: String
    let lastLoginDate: String
    let isPhoneRegistry: Int
    let isEmailRegistry: Int
    let wallets: [String]
    
    init(id: String = "", createdDate: String = "", updatedDate: String = "" , email:String = "" ,phone: String = "", registrationCode: String = "", firstName: String = "", middleName : String = "",lastName: String = "", status: String = "", roles : String = "", registrationIP : String = "",lastLoginIP: String = "", lastLoginDate: String = "", isPhoneRegistry : Int = 0, isEmailRegistry : Int = 0, wallets:[String] = [""]) {
        self.id = id
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.email = email
        self.phone = phone
        self.registrationCode = registrationCode
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.status = status
        self.roles = roles
        self.registrationIP = registrationIP
        self.lastLoginIP = lastLoginIP
        self.lastLoginDate = lastLoginDate
        self.isPhoneRegistry = isPhoneRegistry
        self.isEmailRegistry = isEmailRegistry
        self.wallets = wallets
    }
    
}
