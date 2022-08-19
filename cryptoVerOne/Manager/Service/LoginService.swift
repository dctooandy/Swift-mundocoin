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
    func verificationIDPost(idString:String ,pwString:String) -> Single<String?>
    {
        var parameters: Parameters = [String: Any]()
        parameters = ["id":idString]
        parameters = ["password":pwString]
        return Beans.requestServer.singleRequestPost(
            path: ApiService.verificationID(idString).path,
            parameters: parameters,
            modify: false,
            resultType: String.self).map({
                return $0
            })
    }
    func verificationIDGet(idString:String ) -> Single<String?>
    {
        var parameters: Parameters = [String: Any]()
        parameters = ["id":idString]
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
    
    func customerUpdatePassword(current:String , updated:String , verificationCode:String) -> Single<UpdatePasswordDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["current"] = current
        parameters["updated"] = updated
        parameters["verificationCode"] = verificationCode
        
        return Beans.requestServer.singleRequestPost(
            path: ApiService.customerUpdatePassword.path,
            parameters: parameters,
            modify: false,
            resultType: UpdatePasswordDto.self).map({
                return $0
            })
    }
    func customerLoginHistory(pageable:PagePostDto = PagePostDto(size: "5", page: "0")) -> Single<EmptyDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["page"] = pageable.page
        parameters["size"] = pageable.size
        
        return Beans.requestServer.singleRequestGet(
            path: ApiService.customerLoginHistory.path,
            parameters: parameters,
            modify: false,
            resultType: EmptyDto.self).map({
                return $0
            })
    }
    // 忘記密碼驗證
    func customerForgotPasswordVerify(accountString:String , verificationCode:String) -> Single<ForgotPWVerifyDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["email"] = accountString
        parameters["code"] = verificationCode
        
        return Beans.requestServer.singleRequestPost(
            path: ApiService.customerForgotPasswordVerify.path,
            parameters: parameters,
            modify: false,
            resultType: ForgotPWVerifyDto.self).map({
                return $0
            })
    }
    // 忘記密碼
    func customerForgotPassword(accountString:String , verificationCode:String , newPassword:String) -> Single<String?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["email"] = accountString
        parameters["code"] = verificationCode
        parameters["newPassword"] = newPassword
        
        return Beans.requestServer.singleRequestPost(
            path: ApiService.customerForgotPassword.path,
            parameters: parameters,
            modify: false,
            resultType: String.self).map({
                return $0
            })
    }

}
