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
            control.acceptInputHeightStyle(value)
        }
    }
}

enum InputViewHeightType
{
    case normalInvalidShow
    case pwInvalidShow
    case invalidHidden
}
class InputViewStyleThemes : NSObject {
    static var share = InputViewStyleThemes()
    // MARK: -
    // MARK: 步驟一 內部宣告可監聽狀態
    // 變換有否說明文案高度
    private let inputHeightStyle: BehaviorRelay<InputViewHeightType> = {
        return BehaviorRelay<InputViewHeightType>(value: .invalidHidden)
    }()
    // MARK: -
    // MARK: 步驟二 釋放可設定狀態
    func acceptInputHeightStyle(_ style: InputViewHeightType) {
        inputHeightStyle.accept(style)
    }
    // MARK: -
    // MARK: 步驟三 內部宣告可綁定名稱
    // 綁定取款成功頁面 上方狀態View
    private static let viewHeightMode = InputViewStyleThemes.share.inputHeightStyle.asObservable()
    // MARK: -
    // MARK: 步驟四 內部宣告可綁定參數
    private static func bindNormalInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return viewHeightMode.map({($0 != .normalInvalidShow) ? hidden : show })
    }
    private static func bindPWInputViewHeight<CGFloat>(hidden: CGFloat , show: CGFloat) -> Observable<CGFloat>{
        return viewHeightMode.map({($0 != .pwInvalidShow) ? hidden : show })
    }
    // MARK: -
    // MARK: 步驟五 釋放可全域綁定物件腳
    static let normalInputHeightType : Observable<CGFloat> = bindNormalInputViewHeight(hidden: 85.0, show: Themes.inputViewDefaultHeight)
    static let pwInputHeightType : Observable<CGFloat> = bindPWInputViewHeight(hidden: 85.0, show: Themes.inputViewPasswordHeight)

}
