//
//  UserDefaults+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation


protocol UserDefaultsSettable
{
    associatedtype defaultKeys: RawRepresentable
}

extension UserDefaults
{
    // 驗證用
    struct Verification: UserDefaultsSettable {
        enum defaultKeys: String {
            case status
            case data
            case jwt_token
            case message
            case other
            case error_message
            case error_code
            case agency_pro_tag
            case agency_stage_tag
            case launchBefore
            case BIOList
            case AuditBIOList
            case loged_in
            case fullBanner
            case bioSwitchState
            case auditBioSwitchState
            case askedBioLogin
            case askedAuditBioLogin
            case loginVideoUpdateDate
        }
    }
    struct UserInfo: UserDefaultsSettable {
        enum defaultKeys: String {
            case kConfigInfo
            case kUserInfo
            case kLoginUserInfo
            case kStayPayOrder
            case isFirstOpen
            case isNeedRemenberPwd
            case jpushToken
            case isOpenDanmaku
            case DailyTaskLastOpenDate
            case NeedFetchDailyTask
            case DailyTaskLastOpenArray
            case UserPosition
            case UserShouldJumpPosition
            case isWhenLoginToReloadScheduleBooking
            case isNeedShowBasicTaskCompletedView
            case isOpenedBasicTaskCompletedViewUserArr
        }
    }
    // 目前Domain
    struct DomainType :UserDefaultsSettable{
        enum defaultKeys : String {
            case Domain
        }
    }
    // 登录信息
    struct LoginInfo: UserDefaultsSettable {
        enum defaultKeys: String {
            case token
            case userId
        }
    }
    
    // 登录信息
    struct readNews: UserDefaultsSettable {
        enum defaultKeys: String {
            case sn
        }
    }
    
    // SVG
    struct SVGInfo: UserDefaultsSettable {
        enum defaultKeys: String {
            case isLoadBefore
        }
    }
    
    // Avatar
    struct Avatar: UserDefaultsSettable {
        enum defaultKeys: String {
            case image
        }
    }
    
    //Test
    struct TestAccount: UserDefaultsSettable{
        enum defaultKeys: String {
            case account
            case password
            case realName
        }
    }
}

extension UserDefaultsSettable where defaultKeys.RawValue==String {
    static func set(value: String?, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    static func set(value: [String]?, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    static func set(value: Bool, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    static func string(forKey key: defaultKeys) -> String {
        let aKey = key.rawValue
        if let value = UserDefaults.standard.string(forKey: aKey) {
            return value
        }
        return ""
    }
    static func bool(forKey key: defaultKeys) -> Bool {
        let aKey = key.rawValue
        if let value = UserDefaults.standard.value(forKey: aKey) as? Bool {
            return value
        }
        return false
    }
    
    static func optionBool(forKey key: defaultKeys) -> Bool? {
        let aKey = key.rawValue
        if let value = UserDefaults.standard.value(forKey: aKey) as? Bool {
            return value
        }
        return nil
    }
    
    static func stringArray(forKey key: defaultKeys) -> [String] {
        let aKey = key.rawValue
        if let value = UserDefaults.standard.stringArray(forKey: aKey) {
            return value
        }
        return [String]()
    }
    
    static func delete(forKey key: defaultKeys) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
extension UserDefaults.Avatar {
   static var image : String {
        let aKey = UserDefaults.Avatar.defaultKeys.image.rawValue
        if let value = UserDefaults.standard.string(forKey: aKey) {
            return "avatar\(value)"
        }
        return "avatar1"
    }
    static func setAvatar(value: String) {
        let aKey = UserDefaults.Avatar.defaultKeys.image.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    static var index : Int {
        let aKey = UserDefaults.Avatar.defaultKeys.image.rawValue
        if let value = UserDefaults.standard.string(forKey: aKey) {
            return Int(value) ?? 1
        }
        return 1
    }
}
