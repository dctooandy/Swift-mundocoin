//
//  ForgotPasswordMode.swift
//  cryptoVerOne
//
//  Created by BBk on 11/18/22.
//


import Foundation
enum ForgotPasswordMode {
    case emailPage
    case phonePage
    var inputViewMode : InputViewMode {
        switch self {
        case .emailPage: return .forgotEmail
        case .phonePage: return .forgotPhone
        }
    }
    var forLoginMode : LoginMode {
        switch self {
        case .emailPage: return .emailPage
        case .phonePage: return .phonePage
        }
    }
    var forShowMode : ShowMode {
        switch self {
        case .emailPage: return .forgotEmailPW
        case .phonePage: return .forgotPhonePW
        }
    }
}
