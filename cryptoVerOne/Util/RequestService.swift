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

class RequestService {
    
    private lazy var sessionManager:SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 6
        let manger = SessionManager(configuration: configuration)
        manger.adapter = AccessTokenAdapter()
        return manger
    }()
}

extension RequestService
{
    func singleRequestDelete<T:Codable>(path:URL?,
                                       parameters:Parameters? = nil,
                                       modify:Bool = true,
                                       resultType:T.Type,
                                       encoding: ParameterEncoding = URLEncoding.default) -> Single<T> {
        return singleRequest(path: path, parameters:parameters , modify: modify , resultType: resultType, method: .delete,encoding: encoding)
    }
    func singleRequestPatch<T:Codable>(path:URL?,
                                      parameters:Parameters? = nil,
                                      modify:Bool = true,
                                      resultType:T.Type,
                                      encoding: ParameterEncoding = URLEncoding.default) -> Single<T> {
        return singleRequest(path: path, parameters:parameters , modify: modify , resultType: resultType, method: .patch,encoding: encoding)
    }
    func singleRequestPost<T:Codable>(path:URL?,
                                          parameters:Parameters? = nil,
                                          modify:Bool = true,
                                          resultType:T.Type,
                                          encoding: ParameterEncoding = JSONEncoding.default) -> Single<T> {
        return singleRequest(path: path, parameters:parameters , modify: modify , resultType: resultType, method: .post,encoding: encoding)
    }
    func singleRequestGet<T:Codable>(path:URL?,
                                         parameters:Parameters? = nil,
                                         modify:Bool = true,
                                         resultType:T.Type,
                                         encoding: ParameterEncoding = URLEncoding.default) -> Single<T> {
        return singleRequest(path: path, parameters:parameters , modify: modify , resultType: resultType, method: .get,encoding: encoding)
    }
    func singleRequestPut<T:Codable>(path:URL?,
                                          parameters:Parameters? = nil,
                                          modify:Bool = true,
                                          resultType:T.Type,
                                          encoding: ParameterEncoding = URLEncoding.default) -> Single<T> {
        return singleRequest(path: path, parameters:parameters  , modify: modify , resultType: resultType, method: .put,encoding: encoding)
    }
    func singleRequest<T:Codable>(path:URL?,
                                  parameters:Parameters? = nil,
                                  modify:Bool = true,
                                  resultType:T.Type,
                                  method:HTTPMethod,
                                  encoding: ParameterEncoding = JSONEncoding.default) -> Single<T>
    {
        guard let url = path else {
            Log.errorAndCrash(ApiServiceError.unknownError(0,"","url 解析錯誤"))
        }
        let para = self.transPara(parameters: parameters , modify: modify)
        Log.v("API URL: \(path!)\n=====================\nMethod: \(method)\n=====================\n參數: \(para)")
        return Single<T>.create { observer in
            let task = self.sessionManager
                .request(url,
                         method: method,
                         parameters: para,
                         encoding: encoding)
                .responseCustomModel(T.self,
                                     onData:{ (result: T) in
                                        observer(.success(result)) },
                                     onError:{ (error:ApiServiceError) in
                                        observer(.error(error))})
            
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    //上傳用
    func singleUploadPost<T:Codable>(path:URL?,
                                          imgData:Data? = nil,
                                          parameters:[String:Any] = [:],
                                          modify:Bool = true,
                                          resultType:T.Type) -> Single<T> {
        let para = self.transPara(parameters: parameters , modify: modify)
        Log.v("Upload URL: \(path!)\n=====================\n參數: \(para)")
        return singleUpload(path: path,
                            imgData:imgData ,
                            parameters: para,
                            resultType: resultType,
                            method: .post )
    }
    func singleUpload<T:Codable>(path:URL?,
                                  imgData:Data? = nil,
                                  parameters:[String:Any] = [:],
                                  resultType:T.Type,
                                  method:HTTPMethod) -> Single<T> {

        
        return Single<T>.create { observer in
            _ = self.sessionManager
                .uploadResponseCustomModel(
                    path:path,T.self,
                    imgData:imgData,
                    parameters: parameters ,
                    onData: { (result:T) in observer(.success(result))
            }, onError: { (error:ApiServiceError) in
                observer(.error(error))
            })
            return Disposables.create { () }
        }
    }
    func transPara(parameters : Parameters? , modify:Bool = true) -> Parameters
    {
        var newParameters: Parameters = [String: Any]()
        if let data = parameters
        {
            for name in data.keys {
                newParameters[name] = data[name]
            }
            
        }
        if modify == true
        {
            if UserStatus.share.detectIsLogin() == true
            {
                newParameters["uid"] = UserStatus.share.rUID
                newParameters["token"] = UserStatus.share.rToken
            }
        }
        
        return newParameters
        
    }
}

