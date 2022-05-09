//
//  DataRequest+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import Toaster

extension DataRequest {
    func responseCustomModel<T:Codable,U:Codable>(_ type:T.Type,
                                        meta:U.Type,
                                        onData:((ResponseDto<T,U>) -> Void)? = nil,
                                        onError:((ApiServiceError) -> Void)? = nil) -> Self {
       
        return responseJSON { response in
            print("request api: \(String(describing: response.request?.url))")
            guard let data = response.data else { Log.errorAndCrash("response no data") }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            if let responseString = String(data: data, encoding: .utf8),
               let dict = self.convertToDictionary(text: responseString),
               let status = dict["status"] as? Int {
                //API RESPONSE LOG
                print("response status: \(status)\nresponse data: \(dict as AnyObject)")
                if self.isNeedSaveToken(url:response.request?.url) {
                    if let jwtToken = response.response?.allHeaderFields["JWT-Token"] as? String {
                        Log.v("user token : \(jwtToken)")
                        KeychainManager.share.setToken(jwtToken)
                    }
                }
            }
            
            if let statusCode = response.response?.statusCode {
                
                switch statusCode {
                case 200..<400:
                    do {
                        let results = try decoder.decode(ResponseDto<T,U>.self, from:data)
                        onData?(results)
                    } catch DecodingError.dataCorrupted(let context) {
                        Log.errorAndCrash("Type '\(type)' dataCorrupted:", context.debugDescription)
                    } catch DecodingError.keyNotFound(let key, let context) {
                        Log.errorAndCrash("Type '\(key)' keyNotFound:", context.debugDescription)
                    } catch DecodingError.typeMismatch(let type, let context) {
                        Log.errorAndCrash("Type '\(type)' mismatch:", context.debugDescription)
                    } catch DecodingError.valueNotFound(let value, let context) {
                        Log.errorAndCrash("Type '\(value)' valueNotFound:", context.debugDescription)
                    } catch {
                        Log.errorAndCrash(error.localizedDescription)
                    }
                case 400:
                    do {
                        let msg = try decoder.decode(ResponseRequestErrorDto.self, from:data)
                        print("reponse error status: \(msg.code)")
                        print("reponse error msg: \(msg.message)")
                        switch msg.code {
                        case ErrorCode.ACCOUNT_SIGNUP_FAIL_THRICE_1107,
                             ErrorCode.ACCOUNT_LOGIN_FAIL_THRICE_4009,
                             ErrorCode.PHONE_SIGNUP_LOGIN_FAIL_THRICE_1103:
                            print("註冊登入錯誤大於等於三次")
                            onError?(ApiServiceError.failThrice)
                        case ErrorCode.PROMOTION_CONFLICT :
                            Log.e("優惠衝突")
                            onError?(ApiServiceError.domainError(msg.code, msg.message))
                        case ErrorCode.BAD_REQUEST_EXCEPTION:
                            onError?(ApiServiceError.tokenExpire)
                        default :
                            onError?(ApiServiceError.domainError(msg.code,msg.message))
                        }
                    } catch (let error) {
                        Log.errorAndCrash("Decode error: \(error.localizedDescription)")
                    }
                    
                case 401: onError?(ApiServiceError.tokenExpire)
                case 422:
                    do {
                        let msg = try decoder.decode(ResponseVertifyErrorDto.self, from:data)
                        switch msg.code {
                        case ErrorCode.EMAIL_FORGOT_FAIL_1016,
                             ErrorCode.EMAIL_FORGOT_FAIL_1017,
                             ErrorCode.EMAIL_FORGOT_FAIL_1005:
                            print("Email不存在或其他異常")
                            onError?(ApiServiceError.domainError(msg.code,msg.message))
                            
                        default :
                            onError?(ApiServiceError.networkError(msg.errors?.values.flatMap({$0}).reduce("", { (result, str) -> String in
                                return "\(result) \(str)"
                            }) ?? "unknow error"))
                        }
                    } catch (let error) {
                        onError?(ApiServiceError.unknownError(error.localizedDescription))
                    }
                case 503:
                    do {
                           let msg = try decoder.decode(ResponseRequestErrorDto.self, from:data)
                           onError?(ApiServiceError.systemMaintenance(msg.code, msg.message))
                       } catch (let error) {
                           onError?(ApiServiceError.unknownError(error.localizedDescription))
                       }
                default:
                    onError?(ApiServiceError.unknownError("\(statusCode) unDefine status code error"))
                }
            }
            if let error = response.error {
                onError?(ApiServiceError.unknownError(error.localizedDescription))
            }
        }
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                Log.e(error.localizedDescription)
            }
        }
        return nil
    }
    
    func isNeedSaveToken(url:URL?) -> Bool {
        guard let path = url?.absoluteString.split(separator: "/").last?.description else {return false}
        for url in Constants.saveJWTUrl {
            if url.contains(path) { return true }
        }
        return false
    }
    
}
