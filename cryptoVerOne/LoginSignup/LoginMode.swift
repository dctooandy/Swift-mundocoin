//
//  LoginMode.swift
//  betlead
//
//  Created by Victor on 2019/10/2.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
enum LoginMode {
    case emailPage
    case phonePage
    
    var inputViewMode : InputViewMode {
        switch self {
        case .emailPage: return .email(withStar: true)
        case .phonePage: return .phone(withStar: true)
        }
    }
   
    func verifyPlaceholder() -> String {
        return "Enter the 6-digit code".localized
    }
    
    func signupSuccessTitles() -> SignupSuccessTitle {
        switch self {
        case .phonePage:
            return SignupSuccessTitle(title: "Complete Info", doneButtonTitle: "Start", showAccount: true)
        case .emailPage:
            return SignupSuccessTitle(title: "Welcome to Mundocoin".localized, doneButtonTitle: "Start", showAccount: false)
        }
    }
    
    struct SignupSuccessTitle {
        let title: String
        let doneButtonTitle: String
        let showAccount: Bool
    }
}
