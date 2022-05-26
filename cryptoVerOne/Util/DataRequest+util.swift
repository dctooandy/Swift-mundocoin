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

extension DataRequest
{
    func responseCustomModel<T:Codable>(_ type:T.Type,
                                        onData:((T) -> Void)? = nil,
                                        onError:((ApiServiceError) -> Void)? = nil) -> Self {
        return responseJSON { response in
            let requestPath = response.request?.url?.path ?? ""
            //            let requestQuery = response.request?.url?.query
            let requestURLString = requestPath
            //            let requestURLString = response.request?.url?.absoluteString.components(separatedBy: "/").last ?? "無網址"
            if !Connectivity.isConnectedToInternet {
                // 網路無回應
                onError?(ApiServiceError.networkError(000, requestURLString, ""))
            }
            // 驗證是否有回傳資料
            guard let data = response.data else { Log.errorAndCrash("response no data") }
            // 開始解密
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            var errorMsg = ""
            var apiError : ApiServiceError!
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200..<400:
                    do {
                        // 驗證是否 ret 200
                        if let responseString = String(data: data, encoding: .utf8),
                           let dict = self.convertToDictionary(urlString:requestURLString , text: responseString)
                        {
                            Log.v("正常Response API: \(requestURLString)\n回傳值\nresponse dict keys: \(dict as AnyObject)")
                            if self.isNeedSaveToken(url:response.request?.url) {
                                if  let innerData = dict["token"] as? String
                                {
                                    // Login 回來的
                                    Log.v("Login token : \(innerData)")
                                    KeychainManager.share.setToken(innerData)
                                }
                            }
                            let results = try decoder.decode(T.self, from:data)
                            onData?(results)
                            
                        }else
                        {
                            errorMsg = "資料無法編成"
                            apiError = ApiServiceError.noData
                            let message = "異常Response API: \(requestURLString)\nStatus:\(statusCode)\(type)\n回傳值\nMsg: \(errorMsg)"
                            Log.e("\(message)")
                            onError?(apiError)
                        }
                    }
                    catch DecodingError.dataCorrupted(_) {
                        self.decodeForData(type:"dataCorrupted",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                    }
                    catch DecodingError.keyNotFound(let key, let context) {
                        self.decodeForData(type:"keyNotFound",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                    }
                    catch DecodingError.typeMismatch(let type, let context) {
                        self.decodeForData(type:"typeMismatch",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                    }
                    catch DecodingError.valueNotFound(let value, let context) {
                        self.decodeForData(type:"valueNotFound",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                    }
                    catch {
                        self.decodeForData(requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                    }
                case 422,502,503:
                    self.decodeForData(type:"參數錯誤",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                case 400:
                    self.decodeForData(requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                case 401:
                    self.decodeForData(type:"Unauthorized",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                case 403:
                    self.decodeForData(type:"ACCESS_DENIED",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                case 404:
                    self.decodeForData(type:"Unable to find provided @id/@code",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                default:
                    self.decodeForData(requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                }
            }
            else
            {
                if let error : NSError = response.error as NSError? {
                    Log.v("Error enternal\ncode : \(error.code)\ndomain : \(error.domain)")
                    _ = LoadingViewController.dismiss()
                    switch error.code {
                    case -1001:
                        errorMsg = "網路發生錯誤，請稍後再試".localized
                    case -999:
                        errorMsg = "網路發生錯誤，請稍後再試".localized
                    default:
                        errorMsg = "網路發生錯誤，請稍後再試".localized
                    }
                    apiError = ApiServiceError.showKnownError(error.code,requestURLString,errorMsg)
                    onError?(apiError)
                }else
                {
                    errorMsg = "參數錯誤"
                    apiError = ApiServiceError.showKnownError(-0,requestURLString,errorMsg)
                    onError?(apiError)
                }
            }
        }
    }
    func decodeForData(type:String = "",requestURLString : String ,data : Data , decoder :JSONDecoder , statusCode:Int,onError:((ApiServiceError) -> Void)? = nil)
    {
        var apiError : ApiServiceError!
        do {
            if let responseString = String(data: data, encoding: .utf8),
                let dict = self.convertToDictionary(urlString:requestURLString , text: responseString)
            {
                var results = try decoder.decode(ErrorDefaultDto.self, from:data)
                let message = "異常Response API: \(requestURLString)\nStatus:\(statusCode)\(type)\n回傳值\nresponse dict keys: \(dict as AnyObject)"
                Log.e("\(message)")
                results.httpStatus = "\(statusCode)"
                apiError = ApiServiceError.errorDto(results)
                onError?(apiError)
            }else
            {
                apiError = ApiServiceError.showKnownError(statusCode,requestURLString,"無法解析")
                let message = "異常Response API: \(requestURLString)\nStatus:\(statusCode)\(type)\n回傳值\nMsg: 無法解析"
                Log.e("\(message)")
                onError?(apiError)
            }
        }
        catch {
            let errorMsg = "伺服器繁忙，请稍候再试"
            apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
            let message = "異常Response API: \(requestURLString)\nStatus:\(statusCode)\(type)\n回傳值\nMsg: \(errorMsg)"
            Log.e("\(message)")
            onError?(apiError)
        }
    }
    func isNeedSaveToken(url:URL?) -> Bool {
        guard let path = url?.absoluteString.split(separator: "/").last?.description else {return false}
        for url in Constants.saveJWTUrl {
            if path.contains(url) { return true }
        }
        return false
    }
    func printInfo(_ value: Any) -> Any.Type  {
        let t = type(of: value)
        print("'\(value)' of type '\(t)'")
        return t
    }
    func convertToDictionary(urlString : String = "" , text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                //                Log.e("API: \(urlString)\n=====================\n無法解析的字串: \(text.isEmpty == true ? "無" : text)\n=====================\n字串數 : \(text.count)\n=====================\nError : \(error.localizedDescription)")
                //                if urlString.isEmpty != true
                //                {
                //                    let oneShotAlert = DefaultAlert(mode:.OneShot,message: "API : \(urlString)\n" + "資料解析錯誤，請稍候再試".LocalizedString + "\n" + error.localizedDescription)
                //                    UIApplication.topViewController()?.present(oneShotAlert, animated: true, completion: nil)
                //                }
            }
        }
        return nil
    }
}
