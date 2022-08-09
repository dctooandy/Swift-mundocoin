//
//  InputViewStyleThemes.swift
//  cryptoVerOne
//
//  Created by BBk on 7/20/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: InputViewStyleThemes {
    internal var isShowInvalid: Binder<InputViewHeightType> {
        return Binder(self.base) { control, value in
            Log.v("acceptValue : \(value)")
            if value == .accountInvalidShow || value == .accountInvalidHidden
            {
                control.accountAcceptInputHeightStyle(value)
            }else if value == .pwInvalidShow || value == .pwInvalidHidden
            {
                control.pwAcceptInputHeightStyle(value)
            }else if value == .oldPWInvalidShow || value == .oldPWInvalidHidden
            {
                control.oldAcceptInputHeightStyle(value)
            }else if value == .newPWInvalidShow || value == .newPWInvalidHidden
            {
                control.newAcceptInputHeightStyle(value)
            }else if value == .confirmPWInvalidShow || value == .confirmPWInvalidHidden
            {
                control.confirmAcceptInputHeightStyle(value)
            }else if value == .emailInvalidShow || value == .emailInvalidHidden
            {
                control.emailAcceptInputHeightStyle(value)
            }else if value == .twoFAInvalidShow || value == .twoFAInvalidHidden
            {
                control.twoFAAcceptInputHeightStyle(value)
            }
        }
    }
}

enum InputViewHeightType
{
    case pwInvalidShow
    case pwInvalidHidden
    case accountInvalidShow
    case accountInvalidHidden
    case oldPWInvalidShow
    case oldPWInvalidHidden
    case newPWInvalidShow
    case newPWInvalidHidden
    case confirmPWInvalidShow
    case confirmPWInvalidHidden
    case emailInvalidShow
    case emailInvalidHidden
    case twoFAInvalidShow
    case twoFAInvalidHidden
}
class InputViewStyleThemes : NSObject {
    static var share = InputViewStyleThemes()
    // MARK: -
    // MARK: 步驟一 內部宣告可監聽狀態
    // 變換有否說明文案高度
    private let accountInputHeightStyle: BehaviorRelay<InputViewHeightType> = {
        return BehaviorRelay<InputViewHeightType>(value: .accountInvalidHidden)
    }()
    private let pwInputHeightStyle: BehaviorRelay<InputViewHeightType> = {
        return BehaviorRelay<InputViewHeightType>(value: .pwInvalidHidden)
    }()
    private let oldInputHeightStyle: BehaviorRelay<InputViewHeightType> = {
        return BehaviorRelay<InputViewHeightType>(value: .oldPWInvalidHidden)
    }()
    private let newInputHeightStyle: BehaviorRelay<InputViewHeightType> = {
        return BehaviorRelay<InputViewHeightType>(value: .newPWInvalidHidden)
    }()
    private let confirmInputHeightStyle: BehaviorRelay<InputViewHeightType> = {
        return BehaviorRelay<InputViewHeightType>(value: .confirmPWInvalidHidden)
    }()
    private let emailInputHeightStyle: BehaviorRelay<InputViewHeightType> = {
        return BehaviorRelay<InputViewHeightType>(value: .emailInvalidHidden)
    }()
    private let twoFAInputHeightStyle: BehaviorRelay<InputViewHeightType> = {
        return BehaviorRelay<InputViewHeightType>(value: .twoFAInvalidHidden)
    }()
    // MARK: -
    // MARK: 步驟二 釋放可設定狀態
    func accountAcceptInputHeightStyle(_ style: InputViewHeightType) {
        accountInputHeightStyle.accept(style)
    }
    func pwAcceptInputHeightStyle(_ style: InputViewHeightType) {
        pwInputHeightStyle.accept(style)
    }
    // 更新密碼用
    func oldAcceptInputHeightStyle(_ style: InputViewHeightType) {
        oldInputHeightStyle.accept(style)
    }
    func newAcceptInputHeightStyle(_ style: InputViewHeightType) {
        newInputHeightStyle.accept(style)
    }
    func confirmAcceptInputHeightStyle(_ style: InputViewHeightType) {
        confirmInputHeightStyle.accept(style)
    }
    // 驗證TwoFA用
    func emailAcceptInputHeightStyle(_ style: InputViewHeightType) {
        emailInputHeightStyle.accept(style)
    }
    func twoFAAcceptInputHeightStyle(_ style: InputViewHeightType) {
        twoFAInputHeightStyle.accept(style)
    }
    // MARK: -
    // MARK: 步驟三 內部宣告可綁定名稱
    // 綁定取款成功頁面 上方狀態View
    private static let accountViewHeightMode = InputViewStyleThemes.share.accountInputHeightStyle.asObservable()
    private static let pwViewHeightMode = InputViewStyleThemes.share.pwInputHeightStyle.asObservable()
    private static let oldViewHeightMode = InputViewStyleThemes.share.oldInputHeightStyle.asObservable()
    private static let newViewHeightMode = InputViewStyleThemes.share.newInputHeightStyle.asObservable()
    private static let confirmViewHeightMode = InputViewStyleThemes.share.confirmInputHeightStyle.asObservable()
    private static let emailViewHeightMode = InputViewStyleThemes.share.emailInputHeightStyle.asObservable()
    private static let twoFAViewHeightMode = InputViewStyleThemes.share.twoFAInputHeightStyle.asObservable()
    // MARK: -
    // MARK: 步驟四 內部宣告可綁定參數
    private static func bindNormalInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return accountViewHeightMode.map({($0 == .accountInvalidShow) ? show : hidden })
    }
    private static func bindPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return pwViewHeightMode.map({($0 == .pwInvalidShow) ? show : hidden })
    }
    private static func bindOldPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return oldViewHeightMode.map({($0 == .oldPWInvalidShow) ? show : hidden })
    }
    private static func bindNewPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return newViewHeightMode.map({($0 == .newPWInvalidShow) ? show : hidden })
    }
    private static func bindConfirmPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return confirmViewHeightMode.map({($0 == .confirmPWInvalidShow) ? show : hidden })
    }
    private static func bindEmailInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return emailViewHeightMode.map({($0 == .emailInvalidShow) ? show : hidden })
    }
    private static func bindTwoFAInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return twoFAViewHeightMode.map({($0 == .twoFAInvalidShow) ? show : hidden })
    }
    // MARK: -
    // MARK: 步驟五 釋放可全域綁定物件腳
    static let normalInputHeightType : Observable<CGFloat> = bindNormalInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewDefaultHeight))
    static let pwInputHeightType : Observable<CGFloat> = bindPWInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewPasswordHeight))
    static let oldInputHeightType : Observable<CGFloat> = bindOldPWInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewPasswordHeight))
    static let newInputHeightType : Observable<CGFloat> = bindNewPWInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewPasswordHeight))
    static let confirmInputHeightType : Observable<CGFloat> = bindConfirmPWInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewPasswordHeight))
    static let emailInputHeightType : Observable<CGFloat> = bindEmailInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewDefaultHeight))
    static let twoFAInputHeightType : Observable<CGFloat> = bindTwoFAInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewDefaultHeight))
}
