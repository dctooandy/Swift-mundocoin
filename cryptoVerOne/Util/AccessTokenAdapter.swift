//
//  AccessTokenAdapter.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import Alamofire
import SwiftyJWT

class AccessTokenAdapter: RequestAdapter {
    private var accessToken: String {
        let currentJWT = KeychainManager.share.getToken()
         if !(currentJWT.isEmpty)
        {
            return currentJWT
        }else
        {
           
            return ""
        }
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        //urlRequest.setValue("app", forHTTPHeaderField: "Betlead-Request-Device")
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        //urlRequest.setValue("999", forHTTPHeaderField: "Finger")
        urlRequest.setValue(KeychainManager.share.getFingerID(), forHTTPHeaderField: "Finger")
        urlRequest.setValue("application/json", forHTTPHeaderField:"Accept")
        urlRequest.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
