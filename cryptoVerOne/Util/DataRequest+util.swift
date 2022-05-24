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
            // 測試用
//            let url = response.request?.url?.absoluteString
            // 驗證URL
//            let requestScheme = response.request?.url?.scheme
//            let requestHost = response.request?.url?.host
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
                            Log.v("Response API: \(requestURLString)\n回傳值\nresponse dict keys: \(dict as AnyObject)")
                            if self.isNeedSaveToken(url:response.request?.url) {
                                if  let innerData = dict["data"] as? [String : Any]
                                {
                                    if let infoDic = innerData["info"] as? [[String:Any]],
                                        let jwtToken = infoDic.first!["token"] as? String
                                    {// Login 回來的
                                        Log.v("Login token : \(jwtToken)")
                                        KeychainManager.share.setToken(jwtToken)
                                    }else if let jwtToken = innerData["token"] as? String
                                    {// UserInfo 回來的
                                        Log.v("UserInfo token : \(jwtToken)")
                                        KeychainManager.share.setToken(jwtToken)
                                    }
                                }
                            }
                            let results = try decoder.decode(T.self, from:data)
                            onData?(results)

                        }else
                        {
                            errorMsg = "無法解析資料"
                            apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                            onError?(apiError)
                        }
                    }
                    catch DecodingError.dataCorrupted(_) {
                        errorMsg = "伺服器繁忙，请稍候再试"
                        apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                        onError?(apiError)
                    }
                    catch DecodingError.keyNotFound(let key, let context) {
                        apiError = ApiServiceError.keyNotFound(context.debugDescription , requestURLString , "\(key)")
                        onError?(apiError)
                    }
                    catch DecodingError.typeMismatch(let type, let context) {
                        var errorKeys : [String] = []
                        if let responseString = String(data: data, encoding: .utf8),
                            let dataDic = self.convertToDictionary(text: responseString),
                            let dict = (dataDic["data"] as? [String:Any])
                        {
                            
                            let dicKey = Array(dict.keys.map{ $0 })
                            let dicValue = Array(dict.values.map{ $0 })
                            
                            for i in 0...dicValue.count-1
                            {
                                if self.printInfo(dicKey[i]) != type
                                {
                                    let invalidKey = dicKey[i]
                                    errorKeys.append(invalidKey)
                                }
                            }
                        }
                        apiError = ApiServiceError.typeMismatch(context.debugDescription , requestURLString , "\(type)" ,"\(errorKeys)")
                        onError?(apiError)
                    }
                    catch DecodingError.valueNotFound(let value, let context) {
                        var errorKeys : [String] = []
                        if let responseString = String(data: data, encoding: .utf8),
                            let dataDic = self.convertToDictionary(text: responseString)
                        {
                            if let dictArray = (dataDic["data"] as? [Any])
                            {
                                dictArray.forEach { (dict) in
                                    (dict as! [String : Any?]).forEach { (object) in
                                        if let variableName = object.value as? String ,(variableName as NSString).length > 0
                                        {
                                        } else {
                                            errorKeys.append(object.key)
                                        }
                                    }
                                }
                            }
                            if let dictdic = (dataDic["data"] as? [String:Any])
                            {
                                dictdic.keys.forEach { (key) in
                                    if let variableName = dictdic[key] as? String ,(variableName as NSString).length > 0
                                    {
                                    } else {
                                        errorKeys.append(key)
                                    }
                                }
                            }
                        }
                        apiError = ApiServiceError.valueNotFound(context.debugDescription , requestURLString , "\(value)" ,"\(errorKeys)")
                        onError?(apiError)
                    }
                    catch {
                        errorMsg = error.localizedDescription
                        Log.e(errorMsg)
                        apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                        onError?(apiError)
                    }
                case 403,422,502,503:
                    errorMsg = "參數錯誤"
                    apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                    onError?(apiError)
                case 400:
                    do {
                        if let responseString = String(data: data, encoding: .utf8),
                            let dict = self.convertToDictionary(urlString:requestURLString , text: responseString)
                        {
                            let results = try decoder.decode(ErrorDefaultDto.self, from:data)
                            let message = "Response API: \(requestURLString)\n回傳值\nresponse dict keys: \(dict as AnyObject)"
                            Log.v("\(message)")
                            apiError = ApiServiceError.errorDto(results)
                            onError?(apiError)
                        }
                    }
                    catch {
                        errorMsg = "伺服器繁忙，请稍候再试"
                        apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                        onError?(apiError)
                    }
                    
                case 401:
                    errorMsg = "Unauthorized"
                    apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                    //                    apiError = ApiServiceError.tokenExpire(statusCode,requestURLString,errorMsg)
                    
                    onError?(apiError)
                case 404:
                    errorMsg = "Unable to find provided @id/@code"
                    apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                    onError?(apiError)
                case 405:
                    errorMsg = "Method 不對"
                    apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                    onError?(apiError)
                default:
                    do {
                        if let responseString = String(data: data, encoding: .utf8),
                            let dict = self.convertToDictionary(urlString:requestURLString , text: responseString)
                        {
                            let results = try decoder.decode(ErrorDefaultDto.self, from:data)
                            let message = "Response API: \(requestURLString)\n回傳值\nresponse dict keys: \(dict as AnyObject)"
                            Log.v("\(message)")
                            apiError = ApiServiceError.errorDto(results)
                            onError?(apiError)
                        }else
                        {
                            errorMsg = "header參數錯誤"
                            apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                            onError?(apiError)
                        }
                    }
                    catch {
                        errorMsg = "伺服器繁忙，请稍候再试"
                        apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
                        onError?(apiError)
                    }
                   
                }
//                if errorMsg == ""
//                {
//                    errorMsg = "Server異常,請稍後再試"
//                }
//                apiError = ApiServiceError.showKnownError(statusCode,requestURLString,errorMsg)
//                onError?(apiError)
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
