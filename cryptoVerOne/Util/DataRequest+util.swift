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
                onError?(ApiServiceError.networkError(0, "Connection error, please try again later."))
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
                        let domainString = "\(BuildConfig.MUNDO_SITE_API_HOST)\(requestURLString)"
                        if let responseString = String(data: data, encoding: .utf8)
                        {
                            let dict = self.convertToDictionary(urlString:requestURLString , text: responseString , apiString: "\(domainString)" , statusCode: "\(statusCode)", dtoType: "\(type)")
                            let array = self.convertToArray(urlString:requestURLString , text: responseString, apiString: "\(domainString)" , statusCode: "\(statusCode)", dtoType: "\(type)")
                            if dict != nil || array != nil
                            {
                                let results = try decoder.decode(T.self, from:data)
                                onData?(results)
                            }else if statusCode == 202
                            {
                                // 是 空值或者String
                                onData?("" as! T)
                            }else
                            {
                                self.logByAPI(apiString: "\(domainString)" , statusCode: "\(statusCode)", dtoType: ":\(type)", dataValue:(responseString as AnyObject))
                                let results = try decoder.decode(T.self, from:data.jsonData())
                                onData?(results)
                            }
                        }else
                        {
                            // 無法編成資料
                            errorMsg = "Data could not be compiled"
                            apiError = ApiServiceError.noData
                            self.logByAPI(apiString: "\(domainString)" , statusCode: "\(statusCode)", dtoType: ":\(type)", dataValue: (errorMsg as AnyObject))
                            onError?(apiError)
                        }
                    }
                    catch DecodingError.dataCorrupted(let context) {
                        self.decodeForData(type:"dataCorrupted",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode,keyContext:("key","\(context)"), onError: onError)
                    }
                    catch DecodingError.keyNotFound(let key, let context) {
                        self.decodeForData(type:"keyNotFound",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode,keyContext:("\(key)","\(context)"), onError: onError)
                    }
                    catch DecodingError.typeMismatch(let type, let context) {
                        self.decodeForData(type:"typeMismatch",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode,keyContext:("\(type)","\(context)"), onError: onError)
                    }
                    catch DecodingError.valueNotFound(let value, let context) {
                        self.decodeForData(type:"valueNotFound",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode,keyContext:("\(value)","\(context)"), onError: onError)
                    }
                    catch {
                        self.decodeForData(requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                    }
                case 422,502,503:
                    self.decodeForData(type:"Parameter error",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                case 400:
                    self.decodeForData(requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                case 401:
                    self.decodeForData(type:"Unauthorized",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                case 403:
                    self.decodeForData(type:"ACCESS_DENIED",requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                case 404:
                    self.decodeForData(requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                default:
                    self.decodeForData(requestURLString: requestURLString, data: data, decoder: decoder, statusCode: statusCode, onError: onError)
                }
            }
            else
            {
                if let error : NSError = response.error as NSError? {
                    Log.v("Error enternal\ncode : \(error.code)\ndomain : \(error.domain)")
//                    _ = LoadingViewController.dismiss()
                    switch error.code {
                    case -1001:
                        errorMsg = "A network error occurred, please try again later".localized
                    case -999:
                        errorMsg = "A network error occurred, please try again later".localized
                    default:
                        errorMsg = "A network error occurred, please try again later".localized
                    }
                    apiError = ApiServiceError.showKnownError(error.code,requestURLString,errorMsg)
                    onError?(apiError)
                }else
                {
                    errorMsg = "Parameter error"
                    apiError = ApiServiceError.showKnownError(-0,requestURLString,errorMsg)
                    onError?(apiError)
                }
            }
        }
    }
    func logByAPI(apiString:String,statusCode:String,dtoType:String,dataValue:AnyObject)
    {
        Log.v("正常Response API:\n\(apiString)\n編號:\(statusCode) \nDtoType:\(dtoType)\n回傳值             :\n\(dataValue)")
    }
    func decodeForData(type:String = "",requestURLString : String ,data : Data , decoder :JSONDecoder , statusCode:Int,keyContext:(String,String) = ("","") ,onError:((ApiServiceError) -> Void)? = nil)
    {
        var apiError : ApiServiceError!
        do {
            if let responseString = String(data: data, encoding: .utf8),
                let dict = self.convertToDictionary(urlString:requestURLString , text: responseString)
            {
                var results = try decoder.decode(ErrorDefaultDto.self, from:data)
                let message = "Error Response API:\n\(BuildConfig.MUNDO_SITE_API_HOST)\(requestURLString)\n Status   :\(statusCode)\(type)\nFeedbackValue\n          :\(dict as AnyObject)"
                Log.e("\(message)")
                results.httpStatus = "\(statusCode)"
                apiError = ApiServiceError.errorDto(results)
                onError?(apiError)
            }else
            {
                apiError = ApiServiceError.showKnownError(statusCode,requestURLString,"cannot be parsed-\(keyContext.0)-:-\(keyContext.1)-")
                let message = "Error Response API:\n\(BuildConfig.MUNDO_SITE_API_HOST)\(requestURLString)\n Status   :\(statusCode)\(type)\nFeedbackValue\n          :May be null, cannot be parsed"
                Log.e("\(message)")
                onError?(apiError)
            }
        }
        catch {
            let errorMsg = "-\(keyContext.0)-:-\(keyContext.1)-"
            apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
            let message = "Error Response API:\n\(BuildConfig.MUNDO_SITE_API_HOST)\(requestURLString)\n Status   :\(statusCode)\(type)\nFeedbackValue\n          :\(errorMsg)"
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
    func isNeedSaveAuditToken(url:URL?) -> Bool {
        guard let path = url?.absoluteString.split(separator: "/").last?.description else {return false}
        if path.contains("admin"), path.contains("authentication") { return true }
        return false
    }
    func printInfo(_ value: Any) -> Any.Type  {
        let t = type(of: value)
        print("'\(value)' of type '\(t)'")
        return t
    }
    func convertToDictionary(urlString : String = "" , text: String = "",apiString:String = "",statusCode:String = "",dtoType:String = "") -> [String: Any]?
    {
        if let data = text.data(using: .utf8) {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                {
                    // 是 Dict
                    self.logByAPI(apiString: "\(apiString)" , statusCode: "\(statusCode)", dtoType: "\(dtoType)", dataValue: (dict as AnyObject))
                    return dict
                }else
                {
                    return nil
                }
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
    func convertToArray(urlString : String = "" , text: String,apiString:String = "",statusCode:String = "",dtoType:String = "") -> [AnyObject]?
    {
        if let data = text.data(using: .utf8) {
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject]
                {
                    // 是 Array
                    self.logByAPI(apiString: "\(apiString)" , statusCode: "\(statusCode)", dtoType: "\(dtoType)", dataValue: (array as AnyObject))
                    return array
                }else
                {
                    return nil
                }
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
