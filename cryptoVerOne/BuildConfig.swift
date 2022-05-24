//
//  BuildConfig.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation

class BuildConfig {

    static let Agency_pro_tag = UserDefaults.Verification.bool(forKey: .agency_pro_tag)
    static let Agency_stage_tag = UserDefaults.Verification.bool(forKey: .agency_stage_tag)

    static let HG_EMAIL_COUNT_SECONDS = 120
    static let HG_NORMAL_COUNT_SECONDS = 120
#if DEBUG
    
#else
    
#endif
   

#if Mundo_PRO
    static let MUNDO_SITE_API_HOST = "https://dev.api.mundocoin.com"   // 正式
#elseif Mundo_DEV
    static let MUNDO_SITE_API_HOST = "https://dev.api.mundocoin.com"   // 開發
#elseif Mundo_STAGE
    static let MUNDO_SITE_API_HOST = "https://dev.api.mundocoin.com"   // 測試
#endif
}
