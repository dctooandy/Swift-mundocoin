//
//  BuildConfig.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
enum DomainMode :String{
    case Dev
    case Stage
    case Pro
    
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
   

#if Mundo_PRO
    static var MUNDO_SITE_API_HOST = "https://pro.api.mundocoin.com:443"   // 正式
#elseif Mundo_DEV
    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"    // 開發
#elseif Mundo_STAGE
    static var MUNDO_SITE_API_HOST = "https://\(Domain):443"    // 測試
#endif
    func resetDomain()
    {
        #if Mundo_PRO
        BuildConfig.MUNDO_SITE_API_HOST = "https://pro.api.mundocoin.com:443"   // 正式
        #elseif Mundo_DEV
        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"    // 開發
        #elseif Mundo_STAGE
        BuildConfig.MUNDO_SITE_API_HOST = "https://\(BuildConfig.Domain):443"    // 測試
        #endif
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
        }
        BuildConfig.Domain = UserDefaults.DomainType.string(forKey: .Domain)
    }
}
