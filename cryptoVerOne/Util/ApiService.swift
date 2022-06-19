//
//  ApiService.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift
import Toaster

enum ApiServiceError:Error, Equatable {
    static func == (lhs: ApiServiceError, rhs: ApiServiceError) -> Bool {
        return true
    }
    

    case domainError(Int,String,String)
    case networkError(Int,String,String)
    case tokenError(Int,String,String)
    case tokenExpire(Int,String,String)
    case failThrice(Int,String,String)
    case notLogin(Int,String,String)
    case systemMaintenance(Int,String,String)
    case unknownError(Int,String,String)
    case showKnownError(Int,String,String)
    case showWebContent(Int,String,String)
    case TimeOut_RESPONSE_408(Int,String,String)
    case JsonParseException_RESPONSE_004(Int,String,String)
    case IOException_RESPONSE_000(Int,String,String)
    case Other_RESPONSE_404(Int,String,String)
    
    case valueNotFound(String,String,String,String)
    case typeMismatch(String,String,String,String)
    case keyNotFound(String,String,String)
    case noData
    case errorDto(ErrorDefaultDto)
    
}

enum ApiService {
    
static var host = BuildConfig.MUNDO_SITE_API_HOST
    
    case login
    case forgot
    case reset
    case registration
    case verificationResend(String )
    case verificationIDandCode(String , String)
    case verificationID(String )
    case authentication
    case auditAuthentication
    case approvals
    case walletAddress
    case walletBalances
    case walletWithdraw
    case walletTransactions
    case refreshToken
    case customerUpdatePassword
    
    case signup
    case jpush
    case appVersion
    case banner(String)
    case news(String)
    case member(String)
    case bankCode(String)
    case game(String)
    case promotion(String)
    case gaming(String)
    case base(String)
    
    var path:URL? {
        switch self {
        case .registration:
            return URL(string:ApiService.host + "/v1/registration")
        case .verificationResend(let idString):
            return URL(string: ApiService.host + "/v1/verification/resend/\(idString)")
        case .verificationIDandCode(let idString , let codeString):
            return URL(string: ApiService.host + "/v1/verification/\(idString)/\(codeString)")
        case .verificationID(let idString ):
            return URL(string: ApiService.host + "/v1/verification/\(idString)")
        case .authentication:
            return URL(string:ApiService.host + "/v1/authentication")
        case .walletAddress:
            return URL(string:ApiService.host + "/v1/wallet/address")
        case .walletBalances:
            return URL(string:ApiService.host + "/v1/wallet/balances")
        case .walletTransactions:
            return URL(string:ApiService.host + "/v1/wallet/transactions")
        case .walletWithdraw:
            return URL(string:ApiService.host + "/v1/wallet/withdraw")
        case .refreshToken:
            return URL(string:ApiService.host + "/v1/refresh/token")
        case .customerUpdatePassword:
            return URL(string:ApiService.host + "/v1/customer/updatePassword")

        case .login:
            return URL(string:ApiService.host + "/login") //暫時
        case .appVersion:
             return URL(string:ApiService.host + "/api/FrontendAppVersion")
        case .base(let endpoint):
            return URL(string:ApiService.host + "/api/\(endpoint)")
            
        case .auditAuthentication:
            return URL(string:ApiService.host + "/v1/admin/authentication")
        case .approvals:
            return URL(string:ApiService.host + "/v1/admin/approvals")
        default :
            return URL(string:ApiService.host)
        }
    }
}
