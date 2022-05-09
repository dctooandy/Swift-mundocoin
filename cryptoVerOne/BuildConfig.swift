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
// Test
    static let HG_SITE_TEST_PAYMENT = "http://mtest.betlead.com/forApp"
    static let HG_SITE_TEST_IFRAME = "http://mtest.betlead.com/forApp/bet?path="
    static let HG_SITE_TEST_PROMOTIONDETAIL = "http://mtest.betlead.com/forApp/promotionDetail"
    static let HG_SITE_TEST_GAME_API_HOST =  "https://test.bleadgame.com"
// Stage
    static let HG_SITE_STAGE_PAYMENT = "http://mstage.betlead.com/forApp"
    static let HG_SITE_STAGE_IFRAME = "http://mstage.betlead.com/forApp/bet?path="
    static let HG_SITE_STAGE_PROMOTIONDETAIL = "http://mstage.betlead.com/forApp/promotionDetail"
    static let HG_SITE_STAGE_GAME_API_HOST =  "https://stage.bleadgame.com"
    
    static let HG_EMAIL_COUNT_SECONDS = 120
    static let HG_NORMAL_COUNT_SECONDS = 120
    static let LOGIN_VIDEO_URL = ApiService.host == BuildConfig.HG_SITE_TEST_API_HOST ? "https://test.blstatic.space/upload/movies/apploginmovie.mp4" : "https://stage.blstatic.space/upload/movies/apploginmovie.mp4"
    #if DEBUG
    static let HG_SITE_TEST_API_HOST = "https://test.bleadapi.com"
    static let HG_SITE_API_HOST = "https://stage.bleadapi.com"
    static let HG_SITE_COUNTRY_API_HOST =  "https://test.bleadapi.com"
    #else
    static let HG_SITE_TEST_API_HOST = "https://test.bleadapi.com"
    static let HG_SITE_API_HOST = "https://stage.bleadapi.com"
    static let HG_SITE_COUNTRY_API_HOST = "https://test.bleadapi.com"
    #endif

    #if BETLEADPRO
    static let JPUSH_KEY = "2ba0eadba744d6af8be47c03"
    #else
    static let JPUSH_KEY = "d74f9d6446669cd872c68826"
    #endif
}
