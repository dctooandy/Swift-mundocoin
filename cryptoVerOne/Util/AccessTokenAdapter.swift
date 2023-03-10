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
        //urlRequest.setValue("999", forHTTPHeaderField: "Finger")
//        urlRequest.setValue(KeychainManager.share.getFingerID(), forHTTPHeaderField: "Finger")
        if let urlString = urlRequest.url
        {
            if urlString.pathComponents.contains("wallet") ||
                urlString.pathComponents.contains("refresh") ||
                urlString.pathComponents.contains("update-password") ||
                urlString.pathComponents.contains("approvals") ||
                urlString.pathComponents.contains("approval") ||
                urlString.pathComponents.contains("loginHistory") ||
                urlString.pathComponents.contains("address") ||
                urlString.pathComponents.contains("address-book") ||
                urlString.pathComponents.contains("address-books") ||
                urlString.pathComponents.contains("nickname")
            {
                
                urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            }else if urlString.pathComponents.contains("settings") ,urlString.pathComponents.contains("authentication")
            {
                urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            }else if urlString.pathComponents.contains("currency") ,urlString.pathComponents.contains("settings")
            {
                urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            }
            
            if urlString.pathComponents.contains("resend")
            {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            else if urlString.pathComponents.contains("authentication")
            {
                urlRequest.setValue("application/json", forHTTPHeaderField:"accept")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }else
            {
                urlRequest.setValue("application/json", forHTTPHeaderField:"accept")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
//        urlRequest.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        if let headerData = urlRequest.allHTTPHeaderFields
        {
            Log.v("HttpHeaders:\n\(headerData)\nKeys     :\(headerData.keys)")
        }
        return urlRequest
    }
    
}
