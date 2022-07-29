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
            }else
            {
                control.pwAcceptInputHeightStyle(value)
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
    // MARK: -
    // MARK: 步驟二 釋放可設定狀態
    func accountAcceptInputHeightStyle(_ style: InputViewHeightType) {
        accountInputHeightStyle.accept(style)
    }
    func pwAcceptInputHeightStyle(_ style: InputViewHeightType) {
        pwInputHeightStyle.accept(style)
    }
    // MARK: -
    // MARK: 步驟三 內部宣告可綁定名稱
    // 綁定取款成功頁面 上方狀態View
    private static let accountViewHeightMode = InputViewStyleThemes.share.accountInputHeightStyle.asObservable()
    private static let pwViewHeightMode = InputViewStyleThemes.share.pwInputHeightStyle.asObservable()
    // MARK: -
    // MARK: 步驟四 內部宣告可綁定參數
    private static func bindNormalInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return accountViewHeightMode.map({($0 == .accountInvalidShow) ? show : hidden })
    }
    private static func bindPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return pwViewHeightMode.map({($0 == .pwInvalidShow) ? show : hidden })
    }
    private static func bindOldPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return pwViewHeightMode.map({($0 != .oldPWInvalidShow) ? hidden : show })
    }
    private static func bindNewPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return pwViewHeightMode.map({($0 != .newPWInvalidShow) ? hidden : show })
    }
    private static func bindConfirmPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return pwViewHeightMode.map({($0 != .confirmPWInvalidShow) ? hidden : show })
    }
    // MARK: -
    // MARK: 步驟五 釋放可全域綁定物件腳
    static let normalInputHeightType : Observable<CGFloat> = bindNormalInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewDefaultHeight))
    static let pwInputHeightType : Observable<CGFloat> = bindPWInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewPasswordHeight))
    static let oldInputHeightType : Observable<CGFloat> = bindOldPWInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewPasswordHeight))
    static let newInputHeightType : Observable<CGFloat> = bindNewPWInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewPasswordHeight))
    static let confirmInputHeightType : Observable<CGFloat> = bindConfirmPWInputViewHeight(hidden: 85.0, show: CGFloat(Themes.inputViewPasswordHeight))

}
