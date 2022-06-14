//
//  BuildConfig.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
enum DomainMode :String{
    case Stage
    case Dev
    case Qa
    case Pro
    case AuditStage
    case AuditDev
    case AuditQa
    case AuditPro
}



class BuildConfig {
    static var Domain = UserDefaults.DomainType.string(forKey: .Domain)
    static let Agency_pro_tag = UserDefaults.Verification.bool(forKey: .agency_pro_tag)
    static let Agency_stage_tag = UserDefaults.Verification.bool(forKey: .agency_stage_tag)

    static let HG_EMAIL_COUNT_SECONDS = 120
    static let HG_NORMAL_COUNT_SECONDS = 120
#if DEBUG
    
#else
    
#endif
   
    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"    // 開發
//#if Mundo_PRO
//    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"   // 正式
//#elseif Mundo_DEV
//    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"    // 開發
//#elseif Mundo_STAGE
//    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"    // 測試
//#elseif Approval_PRO
//    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"    // 開發
//#elseif Approval_DEV
//    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"    // 開發
//#elseif Approval_STAGE
//    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"    // 開發
//#endif
    func resetDomain()
    {
        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"    // 開發
//#if Mundo_PRO
//        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"   // 正式
//#elseif Mundo_DEV
//        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"    // 開發
//#elseif Mundo_STAGE
//        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"    // 測試
//#elseif Approval_PRO
//        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"    // 開發
//#elseif Approval_DEV
//        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"    // 開發
//#elseif Approval_STAGE
//        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"    // 開發
//#endif
    }
    func domainSet(mode:DomainMode)
    {
        switch mode
        {
        case .Pro:
            UserDefaults.DomainType.set(value: "pro.api.mundocoin.com", forKey: .Domain)
        case .Dev:
            UserDefaults.DomainType.set(value: "dev.api.mundocoin.com", forKey: .Domain)
        case .Stage:
            UserDefaults.DomainType.set(value: "stage.api.mundocoin.com", forKey: .Domain)
        case .Qa:
            UserDefaults.DomainType.set(value: "qa.api.mundocoin.com", forKey: .Domain)
        case .AuditPro:
            UserDefaults.DomainType.set(value: "pro.api.mundocoin.com", forKey: .Domain)
        case .AuditDev:
            UserDefaults.DomainType.set(value: "dev.api.mundocoin.com", forKey: .Domain)
        case .AuditStage:
            UserDefaults.DomainType.set(value: "stage.api.mundocoin.com", forKey: .Domain)
        case .AuditQa:
            UserDefaults.DomainType.set(value: "qa.api.mundocoin.com", forKey: .Domain)
        }
//#if Mundo_PRO || Mundo_DEV || Mundo_STAGE
//#else
//        switch mode
//        {
//        case .Pro:
//            UserDefaults.DomainType.set(value: "pro.api.mundocoin.com", forKey: .Domain)
//        case .Dev:
//            UserDefaults.DomainType.set(value: "dev.api.mundocoin.com", forKey: .Domain)
//        case .Stage:
//            UserDefaults.DomainType.set(value: "stage.api.mundocoin.com", forKey: .Domain)
//        }
//#endif
        BuildConfig.Domain = UserDefaults.DomainType.string(forKey: .Domain)
    }
}
