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
                Log.e("\(code)"+msg)
                showAlert(title: "错误讯息", message: "\(msg)\n\(urlString)")
            case .networkError(let code ,let urlString):
                Log.e("\(code)")
                showAlert(title: "Network failed", message: "\(code)\n\(urlString)")
            case .unknownError(_ ,let title ,let msg):
                Log.e(msg )
                showAlert(title: title, message: msg )
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
            case .systemMaintenance(let code ,_, _):
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
                if status == "403" , dto.reason == "AUTH_REQUIRED"
                {
                    #if Approval_PRO || Approval_DEV || Approval_STAGE
                    DeepLinkManager.share.handleDeeplink(navigation: .auditLogin)
                    #else
                    DeepLinkManager.share.handleDeeplink(navigation: .login)
                    #endif
                }else
                {
                    var message = ""
                    if errors.count > 0
                    {
                        message = "\(reason)\n\(errors)"
                    }else
                    {
                        message = "\(reason)"
                    }
                    showAlert(title: "\(status) \(code)", message: message)
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
