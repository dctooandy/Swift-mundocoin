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
                showAlert(title: "Error", message: "\(msg)\n\(urlString)")
            case .networkError(let code ,let message):
                Log.e("\(code)\(message)")
                showAlert(title: "Network failed", message: "\(message)")
            case .unknownError(_ , _ ,let msg):
                Log.e(msg )
                showAlert(title: "", message: msg )
            case .tokenError:
                Log.e("tokenExpireError")
                Toast.show(msg:"tokenExpireError")
            case .tokenExpire:
                LoginSignupViewController.share.setMemberViewControllerDefault()
                Toast.show(msg: "Connection timed out, please log in again")
                DeepLinkManager.share.handleDeeplink(navigation: .login)
            case .notLogin:
                showRedictToLoginAlert()
            case .failThrice:
                showAlert(title: "Error", message: "錯誤超過三次")
            case .systemMaintenance(let code ,_, _):
                switch code {
                case ErrorCode.MAINTAIN_B_PLATFORM_EXCEPTION: break
//                    UIApplication.shared.keyWindow?.rootViewController = BetleadSystemMaintainViewController(message: message)
                default:
                    break
                }
            case .showKnownError( _ , _ , let errorMessage ):
                showAlert(title: "", message: "\(errorMessage)")
            case .errorDto(let dto):
                let status = dto.httpStatus ?? ""
//                let code = dto.code
                let reason = dto.reason
                let errors = dto.errors
                if status == "403" , dto.reason == "AUTH_REQUIRED"
                {
                    #if Approval_PRO || Approval_DEV || Approval_STAGE
                    DeepLinkManager.share.handleDeeplink(navigation: .auditLogin)
                    #else
                    DeepLinkManager.share.handleDeeplink(navigation: .login)
                    #endif
                }
                var message = ""
                if errors.count > 0
                {
                    message = "\(reason)"
                    for subdata in errors
                    {
                        if subdata.rejectValue != "n/a"
                        {
                            message.append("\n" + subdata.field + "\n" + subdata.reason + "\n" + subdata.rejectValue)                            
                        }
                    }
                }else
                {
                    message = "\(reason)"
                }
                showAlert(title: "", message: message)
                
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
            if let currentVC = UIApplication.topViewController()
            {
                let stringHeight = message.height(withConstrainedWidth: (Views.screenWidth - 116), font: Fonts.PlusJakartaSansMedium(16))
                let popVC = ConfirmPopupView(viewHeight: stringHeight,
                                             iconMode: .nonIcon(["Close".localized]),
                                             title: title,
                                             message: message ){ _ in }
                popVC.start(viewController: currentVC)
            }else
            {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                })
                alert.addAction(okAction)
                UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    static func showRedictToLoginAlert() {
        UIApplication.topViewController()?.present(LoginAlert(), animated: true, completion: nil)
    }
    
}
