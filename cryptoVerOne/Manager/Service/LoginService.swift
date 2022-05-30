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
    func signUPRegistration(code:String ,
                            email:String = "" ,
                            password:String ,
                            phone:String = "",
                            verificationCode : String) -> Single<RegistrationDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters = ["code":code,
                      "password":password,
                      "verificationCode":verificationCode]
        if email.isEmpty
        {
            parameters["phone"] = phone
        }else
        {
            parameters["email"] = email
        }
        return Beans.requestServer.singleRequestPost(
            path: ApiService.registration.path,
            parameters: parameters,
            modify: false,
            resultType: RegistrationDto.self).map({
                return $0
            })
    }
    func verificationResend(idString:String) -> Single<ResendDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["id"] = idString
        return Beans.requestServer.singleRequestPost(
            path: ApiService.verificationResend(idString).path,
            parameters: parameters,
            modify: false,
            resultType: ResendDto.self).map({
                return $0
            })
    }
    func verification(idString:String , codeString : String) -> Single<String?>
    {
        var parameters: Parameters = [String: Any]()
        parameters = ["id":idString,
                      "code":codeString]
        return Beans.requestServer.singleRequestGet(
            path: ApiService.verificationIDandCode(idString, codeString).path,
            parameters: parameters,
            modify: false,
            resultType: String.self).map({
                return $0
            })
    }
    func verificationID(idString:String ,asLoginUser:Bool) -> Single<String?>
    {
        var parameters: Parameters = [String: Any]()
        parameters = ["id":idString]
        if asLoginUser == true
        {
            parameters["asLoginUser"] = "true"
        }else
        {
            parameters["asLoginUser"] = "false"
        }
        return Beans.requestServer.singleRequestGet(
            path: ApiService.verificationID(idString).path,
            parameters: parameters,
            modify: false,
            resultType: String.self).map({
                return $0
            })
    }
    func authentication(with idString:String , password:String , verificationCode:String = "")  -> Single<AuthenticationDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters = ["id":idString,
                      "password":password]
        if !verificationCode.isEmpty
        {
            parameters["verificationCode"] = verificationCode
        }
        return Beans.requestServer.singleRequestPost(
            path: ApiService.authentication.path,
            parameters: parameters,
            modify: false,
            resultType: AuthenticationDto.self).map({
                return $0
            })
    }
    
    func refreshToken() -> Single<AuthenticationDto?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestGet(
            path: ApiService.refreshToken.path,
            parameters: parameters,
            modify: false,
            resultType: AuthenticationDto.self).map({
                return $0
            })
    }
    
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
                return $0
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
                return $0
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
                return $0
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
                return $0
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
                return $0
            })
    }
}
