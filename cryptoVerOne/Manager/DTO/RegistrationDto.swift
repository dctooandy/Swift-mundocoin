//
//  RegistrationDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
import RxSwift

class RegistrationDto :Codable{
    static var share:RegistrationDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<RegistrationDto?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update(done: {})
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<RegistrationDto?>(value: nil)
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
    
    
    var createdDate : String = ""
    var email : String = ""
    var firstName : String?
    var id : String = ""
    var isEmailRegistry : JSONValue = .int(1)
    var isPhoneRegistry : JSONValue = .int(1)
    var lastLoginDate : String?
    var lastLoginIP : String?
    var lastName : String?
    var middleName : String?
    var phone : String?
    var registrationCode : String = ""
    var registrationIP : String = ""
    var roles : String = ""
    var status : String = ""
    var updatedDate : String = ""
    var wallet : String?
    
   
    init(createdDate: String = "", email: String = "", firstName: String = "", id : String = "",
         isEmailRegistry: JSONValue = .int(1), isPhoneRegistry: JSONValue = .int(1), lastLoginDate: String = "" ,lastLoginIP : String = "",lastName: String = "", middleName: String = "", phone: String = "" , registrationCode : String = "",registrationIP: String = "", roles: String = "", status: String = "" , updatedDate : String = "" , wallet : String = "") {
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
        self.wallet = wallet
    }
}
