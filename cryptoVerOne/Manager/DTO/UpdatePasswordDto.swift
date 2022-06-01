//
//  UpdatePasswordDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/1/22.
//


import Foundation
import RxSwift

class UpdatePasswordDto :Codable{
    static var share:UpdatePasswordDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<UpdatePasswordDto?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update(done: {})
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<UpdatePasswordDto?>(value: nil)
    static func update(done: @escaping () -> Void) -> Observable<()>{
        let subject = PublishSubject<Void>()
//        Beans.userServer.fetchUserInfo().subscribeSuccess({ (userInfoDto) in
//            share = userInfoDto
//            share?.isNeedHeadOffNaviPopEvent = false
//            _ = LoadingViewController.dismiss()
//            done()
//            subject.onNext(())
//        }).disposed(by: disposeBag)
        return subject.asObservable()
    }
    
            var id : String = ""
            var createdDate : String = ""
            var updatedDate : String = ""
            var email : String = ""
            var phone : String?
            var registrationCode : String = ""
            var firstName : String?
            var middleName : String?
            var lastName : String?
            var status : String = ""
            var roles : String = ""
            var registrationIP : String = ""
            var lastLoginIP : String?
            var lastLoginDate : String?
            var isPhoneRegistry : JSONValue = .int(1)
            var isEmailRegistry : JSONValue = .int(1)
            var wallets : [WalletAddressDto]?
    
    
   
    init(createdDate: String = "", email: String = "", firstName: String = "", id : String = "",
         isEmailRegistry: JSONValue = .int(1), isPhoneRegistry: JSONValue = .int(1), lastLoginDate: String = "" ,lastLoginIP : String = "",lastName: String = "", middleName: String = "", phone: String = "" , registrationCode : String = "",registrationIP: String = "", roles: String = "", status: String = "" , updatedDate : String = "" , wallets:[WalletAddressDto] = [WalletAddressDto()]) {
        self.createdDate = createdDate
        self.email = email
        self.firstName = firstName
        self.id = id
        self.isEmailRegistry = isEmailRegistry
        self.isPhoneRegistry = isPhoneRegistry
        self.lastLoginDate = lastLoginDate
        self.lastLoginIP = lastLoginIP
        self.lastName = lastName
        self.middleName = middleName
        self.phone = phone
        self.registrationCode = registrationCode
        self.registrationIP = registrationIP
        self.roles = roles
        self.status = status
        self.updatedDate = updatedDate
        self.wallets = wallets
    }
}
