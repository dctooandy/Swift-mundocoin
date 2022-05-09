//
//  ErrorHandler.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import Toaster

class ErrorHandler {
    
    static func show(error:Error) {
        if let error = error as? ApiServiceError {
            switch error {
            case .domainError(let (_,msg)):
                Log.e(msg)
                showAlert(title: "错误讯息", message: msg)
            case .networkError(let msg):
                Log.e(msg ?? " no error message")
                showAlert(title: "错误讯息", message: msg ?? "")
            case .unknownError(let msg):
                Log.e(msg ?? " no error message")
                showAlert(title: "错误讯息", message: msg ?? "")
            case .tokenError:
                Log.e("tokenExpireError")
                Toast.show(msg:"tokenExpireError")
            case .tokenExpire:
                KeychainManager.share.clearToken()
                //KeychainManager.share.deleteValue(at: .account)
//                WalletDto.share = nil
//                MemberProfileDto.share = nil
//                BankCardDto.share = nil
//                MemberDto.share = nil
//                AccountVerifyDto.share = nil
                LoginSignupViewController.share.setMemberViewControllerDefault()
                Toast.show(msg: "连线逾时请重新登入")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
//                    UIApplication.shared.keyWindow?.rootViewController =  LoginSignupViewController.share.isLogin(true)
                    UIApplication.shared.keyWindow?.rootViewController =  LoginSignupViewController.share.showMode(.login)
                })
            case .notLogin:
                showRedictToLoginAlert()
            case .failThrice:
                showAlert(title: "错误讯息", message: "錯誤超過三次")
            case .systemMaintenance(let code , let message):
                switch code {
                case ErrorCode.MAINTAIN_B_PLATFORM_EXCEPTION: break
//                    UIApplication.shared.keyWindow?.rootViewController = BetleadSystemMaintainViewController(message: message)
                default:
                    break
                }
            }
        } else {
            Toast.show(msg:"unDefine error type")
        }
    }
    
    static func showAlert(title: String, message: String){
        if UIApplication.topViewController() is LoadingViewController {
            _ = LoadingViewController.action(mode: .fail, title: message)
        } else {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {(action) in
            })
        alert.addAction(okAction)
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showRedictToLoginAlert() {
        UIApplication.topViewController()?.present(LoginAlert(), animated: true, completion: nil)
    }
    
}
