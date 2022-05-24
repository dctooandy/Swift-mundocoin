//
//  SessionManager+util.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import Toaster

extension SessionManager
{
    func uploadResponseCustomModel<T:Codable>(
        path:URL?,
        _ type:T.Type,
        imgData:Data? = nil,
        parameters:[String:Any] = [:],
        onData:((MundoResponseDto<T>) -> Void)? = nil,
        onError:((ApiServiceError) -> Void)? = nil) -> Void
    {
        guard let url = path else {
            Log.errorAndCrash(ApiServiceError.unknownError(0,"","url 解析錯誤"))
        }
        _ = self.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imgData!,
                                     withName: "file_name",
                                     fileName: "\(self.randomString(length: 5)).jpeg",
                                     mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
        }, to: url, encodingCompletion: { (result) in
            switch result {
              case .success(let upload, _, _):
                _ = upload.responseCustomModel(T.self,
                onData:{ (result:MundoResponseDto<T>) in
                    onData?(result) },
                onError:{ (error:ApiServiceError) in
                   onError?(error)})
              case .failure(let encodingError):
                  print(encodingError)
                  onError?(encodingError as! ApiServiceError)
              }
        })
    }
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
