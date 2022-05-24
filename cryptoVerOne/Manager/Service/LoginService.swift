//
//  LoginService.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//


import Foundation
import RxCocoa
import RxSwift
import Alamofire

class LoginService {
    func loginUserLogin(with account:String , password:String) -> Single<LoginDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters = ["user_login":account,
                      "user_pass":password]
        let jpushString = UserDefaults.UserInfo.string(forKey: .jpushToken)        
        parameters["pushid"] = jpushString
        
        return Beans.requestServer.singleRequestPost(
            path: ApiService.login.path,
            parameters: parameters,
            modify: false,
            resultType: LoginDto.self).map({
                return $0.data
            })
    }
    func loginForgetPwdGetVerfiCode(mobile: String, sign: String) -> Single<DefaultDto?>{
        var parameters: Parameters = [String: Any]()
        parameters = [
            "mobile": mobile,
            "sign": sign,
            "source": "ios",
        ]
        return Beans.requestServer.singleRequestPost(
//            path: ApiService.loginForget("getForgetCode").path,
            path: ApiService.forgot.path,
            parameters: parameters,
            resultType: DefaultDto.self).map({
                return $0.data
            })
    }
    func loginResetPwd(account: String, pwd: String, checkPwd: String, verfiCode: String)-> Single<DefaultDto?>{
        var parameters: Parameters = [String: Any]()
        parameters = [
            "source": "ios",
            "code": verfiCode,
            "user_login": account,
            "user_pass": pwd,
            "user_pass2": checkPwd
        ]
        return Beans.requestServer.singleRequestPost(
//            path: ApiService.loginForget("userFindPass").path,
            path: ApiService.reset.path,
            parameters: parameters,
            resultType: DefaultDto.self).map({
                return $0.data
            })
    }
    
    func loginSignUpGetVerfiCode(mobile: String, sign: String) -> Single<DefaultDto?>{
        var parameters: Parameters = [String: Any]()
        parameters = [
            "mobile": mobile,
            "sign": sign,
            "source": "ios",
        ]
        return Beans.requestServer.singleRequestPost(
//            path: ApiService.loginForget("getCode").path,
            path: ApiService.signup.path,
            parameters: parameters,
            resultType: DefaultDto.self).map({
                return $0.data
            })
    }
    
    func loginSignUp(account: String, pwd: String, checkPwd: String, verfiCode: String)-> Single<DefaultDto?>{
        var parameters: Parameters = [String: Any]()
        parameters = [
            "source": "ios",
            "code": verfiCode,
            "user_login": account,
            "user_pass": pwd,
            "user_pass2": checkPwd
        ]
        return Beans.requestServer.singleRequestPost(
//            path: ApiService.loginForget("userReg").path,
            path: ApiService.signup.path,
            parameters: parameters,
            resultType: DefaultDto.self).map({
                return $0.data
            })
    }
}
