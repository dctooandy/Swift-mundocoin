//
//  RequestServer.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import Alamofire
import RxCocoa
import RxSwift
import Toaster

enum ApiServiceError:Error, Equatable {
    case networkError(String?)
    case tokenError
    case tokenExpire
    case domainError(Int,String)
    case failThrice
    case notLogin
    case systemMaintenance(Int,String)
    case unknownError(String?)
    
}

enum ApiService {
    //  static let host = "http://localhost:1460"
    static let host = BuildConfig.HG_SITE_API_HOST // stage
    static let gameingHost = BuildConfig.HG_SITE_STAGE_GAME_API_HOST // stage
//    static let host = BuildConfig.HG_SITE_TEST_API_HOST // test
//    static let gameingHost = BuildConfig.HG_SITE_TEST_GAME_API_HOST // test
    static let countryHost = BuildConfig.HG_SITE_COUNTRY_API_HOST
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
        case .jpush:
            return URL(string:ApiService.host + "/api/FrontendPushDevice")
        case .appVersion:
             return URL(string:ApiService.host + "/api/FrontendAppVersion")
        case .banner(let endpoint):
            return URL(string:ApiService.host + "/api/FrontendBanner/\(endpoint)")
        case .news(let endpoint):
            return URL(string:ApiService.host + "/api/FrontendNews/\(endpoint)")
        case .member(let endpoint):
            return URL(string:ApiService.host + "/api/Member/\(endpoint)")
        case .bankCode(let endpoint):
            return URL(string:ApiService.host + "/api/BankCode/\(endpoint)")
        case .game(let endpoint):
            return URL(string:ApiService.host + "/api/\(endpoint)")
        case .promotion(let endpoint):
            return URL(string:ApiService.host + "/api/\(endpoint)")
        case .gaming(let endpoint):
            return URL(string:ApiService.gameingHost + "/api/Game/\(endpoint)")
        case .base(let endpoint):
            return URL(string:ApiService.host + "/api/\(endpoint)")
        }
    }
}

class RequestServer {
    
    private lazy var sessionManager : SessionManager = {
        let manger = SessionManager()
        manger.adapter = AccessTokenAdapter()
        return manger
    }()
    
    func singleRequestGet<T:Codable,U:Codable>(path:URL?,
                                               parameters:Parameters? = nil,
                                               resultType:T.Type,
                                               meta:U.Type) -> Single<ResponseDto<T,U>> {
       return singleRequest(path: path,parameters:parameters, resultType: resultType, meta: meta, method: .get)
    }
    
    func singleRequestGet<T:Codable>(path:URL?,
                                               parameters:Parameters? = nil,
                                               resultType:T.Type) -> Single<ResponseDto<T,[String:String]?>> {
        return singleRequest(path: path, parameters:parameters , resultType: resultType, method: .get)
    }
    
    func singleRequestPost<T:Codable,U:Codable>(path:URL?,
                                                parameters:Parameters? = nil,
                                                resultType:T.Type,
                                                meta:U.Type) -> Single<ResponseDto<T,U>> {
         return singleRequest(path: path,parameters:parameters, resultType: resultType, meta: meta, method: .post)
    }
    
    func singleRequestPost<T:Codable>(path:URL?,
                                      parameters:Parameters? = nil,
                                      resultType:T.Type) -> Single<ResponseDto<T,[String:String]?>> {
        return singleRequest(path: path, parameters:parameters , resultType: resultType, method: .post)
    }
    
    func singleRequestPatch<T:Codable,U:Codable>(path:URL?,
                                                parameters:Parameters? = nil,
                                                resultType:T.Type,
                                                meta:U.Type) -> Single<ResponseDto<T,U>> {
        return singleRequest(path: path,parameters:parameters, resultType: resultType, meta: meta, method: .patch)
    }
    
    func singleRequestPatch<T:Codable>(path:URL?,
                                      parameters:Parameters? = nil,
                                      resultType:T.Type) -> Single<ResponseDto<T,[String:String]?>> {
        return singleRequest(path: path, parameters:parameters , resultType: resultType, method: .patch)
    }
    
    func singleRequestDelete<T:Codable,U:Codable>(path:URL?,
                                                 parameters:Parameters? = nil,
                                                 resultType:T.Type,
                                                 meta:U.Type) -> Single<ResponseDto<T,U>> {
        return singleRequest(path: path,parameters:parameters, resultType: resultType, meta: meta, method: .delete)
    }
    
    func singleRequestDelete<T:Codable>(path:URL?,
                                       parameters:Parameters? = nil,
                                       resultType:T.Type) -> Single<ResponseDto<T,[String:String]?>> {
        return singleRequest(path: path, parameters:parameters , resultType: resultType, method: .delete)
    }
    
    func singleRequest<T:Codable,U:Codable>(path:URL?,
                                            parameters:Parameters? = nil,
                                            resultType:T.Type,
                                            meta:U.Type,
                                            method:HTTPMethod) -> Single<ResponseDto<T,U>> {
        guard let url = path else {
            Log.errorAndCrash(ApiServiceError.unknownError("url parse fail").localizedDescription)
        }
        
        return Single<ResponseDto<T,U>>.create { observer in
            let task = self.sessionManager
                .request(url, method:method, parameters: parameters)
                .responseCustomModel(T.self,
                                     meta:U.self,
                                     onData:{ (result:ResponseDto<T,U>) in
                                        observer(.success(result))},
                                     onError:{ (error:ApiServiceError) in
                                        Log.e(url)
                                        observer(.error(error))})
            
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    func singleRequest<T:Codable>(path:URL?,
                                  parameters:Parameters? = nil,
                                  resultType:T.Type,
                                  method:HTTPMethod) -> Single<ResponseDto<T,[String:String]?>> {
        guard let url = path else {
            Log.errorAndCrash(ApiServiceError.unknownError("url parse fail").localizedDescription)
        }
        
        return Single<ResponseDto<T,[String:String]?>>.create { observer in
            let task = self.sessionManager.request(url, method: method, parameters: parameters)
                .responseCustomModel(T.self,meta:[String:String]?.self,
                                     onData:{ (result:ResponseDto<T,[String:String]?>) in
                                        observer(.success(result)) },
                                     onError:{ (error:ApiServiceError) in
                                        Log.e(url)
                                        observer(.error(error))})
            
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}

