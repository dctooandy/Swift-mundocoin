//
//  Constants.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation

struct ErrorCode {
    static let ACCOUNT_LOGIN_FAIL_THRICE_4009 = 4009
    static let ACCOUNT_SIGNUP_FAIL_THRICE_1107 = 1107
    static let PHONE_SIGNUP_LOGIN_FAIL_THRICE_1103 = 1103
    static let EMAIL_FORGOT_FAIL_1016 = 1016
    static let EMAIL_FORGOT_FAIL_1017 = 1017
    static let EMAIL_FORGOT_FAIL_1005 = 1005
    static let PROMOTION_CONFLICT = 3006
    static let BAD_REQUEST_EXCEPTION = 1350
    static let MAINTAIN_B_PLATFORM_EXCEPTION = 9100
    static let MAINTAIN_B_DW_EXCEPTION = 9200
    static let MAINTAIN_B_SPORT_EXCEPTION = 9300
}

class Constants {

    // bypass save jwt url
    static let saveJWTUrl = ["authentication","token"]

}

class NotifyConstant {
    static let betleadAccountVerifyUpdated = Notification.Name("betleadAccountVerifyUpdated")
    static let betleadMemberUpdated = Notification.Name("betleadMemberUpdated")
    static let betleadBankCardUpdated = Notification.Name("betleadBankCardUpdated")
    static let betleadGameGroupIdUpdated = Notification.Name("betleadGameGroupIdUpdated")
    static let betleadVCRelaodData = Notification.Name("betleadVCRelaodData")
    static let betleadWalletUpdated = Notification.Name("betleadWalletUpdated")
    static let betleadShowBlur = Notification.Name("betleadShowBlur")
    static let betleadCleanBlur = Notification.Name("betleadCleanBlur")
    static let betleadShowGiveupBtn = Notification.Name("betleadShowGiveupBtn")
}
struct ApiCode {
    
    static let kDefaultSuccessCode = 200
}
