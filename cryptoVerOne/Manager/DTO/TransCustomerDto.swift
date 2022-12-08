//
//  TransCustomerDto.swift
//  cryptoVerOne
//
//  Created by BBk on 10/28/22.
//

import Foundation
import RxSwift

class TransCustomerDto :Codable {

    var id:String = ""
    var createdDate: String = ""
    var updatedDate: String = ""
    var email: String? = ""
    var firstName: JSONValue? = JSONValue.string("")
    var middleName: JSONValue? = JSONValue.string("")
    var lastName: JSONValue? = JSONValue.string("")
    var phone: JSONValue? = JSONValue.string("")
    var registrationCode: String? = ""
    var registrationIP: String? = ""
    var roles: String? = ""
    var status: String? = ""
    var isAddressBookWhiteListEnabled:Bool = false
    var isEmailRegistry:Bool = false
    var isPhoneRegistry:Bool = false
    var lastLoginDate: JSONValue? = JSONValue.string("")
    var lastLoginIP: String = ""
    var nickName:String? = ""
    init(id: String = "",createdDate: String = "", updatedDate: String = "" , email: String = "", firstName:JSONValue? = JSONValue.string(""), middleName: JSONValue? = JSONValue.string("") , lastName: JSONValue? = JSONValue.string(""), phone: JSONValue? = JSONValue.string(""), registrationCode: String? = "", registrationIP: String? = "", roles: String? = "", status: String? = "", isAddressBookWhiteListEnabled: Bool = false , isEmailRegistry: Bool = false, isPhoneRegistry: Bool = false ,lastLoginDate: JSONValue? = JSONValue.string(""),lastLoginIP: String = "" , nickName:String = "") {
        
        self.id = id
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.email = email
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.phone = phone
        self.registrationCode = registrationCode
        self.registrationIP = registrationIP
        self.roles = roles
        self.status = status
        self.isAddressBookWhiteListEnabled = isAddressBookWhiteListEnabled
        self.isEmailRegistry = isEmailRegistry
        self.isPhoneRegistry = isPhoneRegistry
        self.lastLoginDate = lastLoginDate
        self.lastLoginIP = lastLoginIP
        self.nickName = nickName
    }
}
