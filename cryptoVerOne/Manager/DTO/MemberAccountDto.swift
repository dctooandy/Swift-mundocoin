//
//  MemberAccountDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/27/22.
//

import Foundation
class MemberAccountDto {
    static var share: MemberAccountDto?
    var account: String = ""
    var password: String = ""
    var loginMode: LoginMode = .emailPage
    var phone: String = ""
    var registrationInfo:String = ""
    var email:String = ""
    var mobile:String = ""
    var memberSince:String = ""
    var timestamp:Int = 0
//    private var _nickName:String = "Mundocoin-User"
    var nickName:String = "Mundocoin-User"
    
    var isAccountLocked:Bool = false
    var registrationDate:Int = 0
    var Id:String = ""
    var isAccountEnabled:Bool = false
    var isAddressBookWhiteListEnabled:Bool = false
    var isPasswordExpired:Bool = false
    var sub:String = ""
    var isAccountExpired:Bool = false
    
    init(isAccountLocked : Bool = false,
         registrationDate : Int = 0,
         Id :String = "",
         isAccountEnabled : Bool = false,
         isAddressBookWhiteListEnabled : Bool = false,
         isPasswordExpired : Bool = false,
         sub : String = "",
         isAccountExpired : Bool = false) {
        self.isAccountLocked = isAccountLocked
        self.registrationDate = registrationDate
        self.Id = Id
        self.isAccountEnabled = isAccountEnabled
        self.isAddressBookWhiteListEnabled = isAddressBookWhiteListEnabled
        self.isPasswordExpired = isPasswordExpired
        self.sub = sub
        self.isAccountExpired = isAccountExpired
    }
    func cleanAllData()
    {
        MemberAccountDto.share = nil
    }
    func memberSinceDate() -> String
    {
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMMM, yyyy"
        let date = Date(timeIntervalSince1970: TimeInterval((registrationDate/1000)))
        let strDate = newDateFormatter.string(from: date)
        return strDate
    }
}
