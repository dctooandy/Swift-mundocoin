//
//  ErrorHandler.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import Toaster
import RxSwift
import RxCocoa

class ErrorHandler {
    static var disposteBag = DisposeBag()
    static func show(error:Error) {
        if let error = error as? ApiServiceError {
            switch error {
            case .domainError(let code ,let urlString ,let msg):
                Log.e(msg)
                showAlert(title: "错误讯息", message: msg)
            case .networkError(let code ,let urlString ,_):
                Log.e("\(code)")
                showAlert(title: "Network failed", message: "\(code)")
            case .unknownError(let code ,let urlString ,let msg):
                Log.e(msg ?? " no error message")
                showAlert(title: "错误讯息", message: msg ?? "")
            case .tokenError:
                Log.e("tokenExpireError")
                Toast.show(msg:"tokenExpireError")
            case .tokenExpire:
                LoginSignupViewController.share.setMemberViewControllerDefault()
                Toast.show(msg: "连线逾时请重新登入")
                DeepLinkManager.share.handleDeeplink(navigation: .login)
            case .notLogin:
                showRedictToLoginAlert()
            case .failThrice:
                showAlert(title: "错误讯息", message: "錯誤超過三次")
            case .systemMaintenance(let code ,_, let message):
                switch code {
                case ErrorCode.MAINTAIN_B_PLATFORM_EXCEPTION: break
//                    UIApplication.shared.keyWindow?.rootViewController = BetleadSystemMaintainViewController(message: message)
                default:
                    break
                }
            case .showKnownError(let statusInt , let urlString , let errorMessage ):
                showAlert(title: "httpStatus:\(statusInt)", message: "\(BuildConfig.Domain)\(urlString)\n\(errorMessage)")
            case .errorDto(let dto):
                let status = dto.httpStatus ?? ""
                let code = dto.code
                let reason = dto.reason
                let errors = dto.errors
                if status == "403" , dto.reason == "TOKEN_EXPIRED"
                {
                    DeepLinkManager.share.handleDeeplink(navigation: .login)
                }else if status == "403" , dto.reason == "AUTH_REQUIRED"
                {
                    DeepLinkManager.share.handleDeeplink(navigation: .login)
                }else
                {
                    showAlert(title: "\(status):\(code)", message: "\(reason)\n\(errors)")
                }
            case .noData:
                break
            default: break
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
