//
//  WalletSecurityThemes.swift
//  cryptoVerOne
//
//  Created by BBk on 6/23/22.
//

import Foundation
import UIKit
import Foundation
import RxSwift
import RxCocoa

class WalletSecurityThemes {
    static var share = WalletSecurityThemes()
    // MARK: -
    // MARK: 步驟一 內部宣告可監聽狀態
    // 變換取款成功頁面上方狀態
    // 開啟關閉金額
    private let moneySecureStyle: BehaviorRelay<SecureStyle> = {
        return BehaviorRelay<SecureStyle>(value: .visible)
    }()
    // MARK: -
    // MARK: 步驟二 釋放可設定狀態
    func acceptMoneySecureStyle(_ style: SecureStyle) {
        if moneySecureStyle.value == .visible {
            moneySecureStyle.accept(.nonVisible)
        } else {
            moneySecureStyle.accept(.visible)
        }
    }
    // MARK: -
    // MARK: 步驟三 內部宣告可綁定名稱
    // 綁定 輸入框typing狀態的border
    private static let moneySecureMode = WalletSecurityThemes.share.moneySecureStyle.asObservable()
    // MARK: -
    // MARK: 步驟四 內部宣告可綁定參數
    private static func bindVisibleOrNotStyle<T>(visible: T, none: T) -> Observable<T> {
        return WalletSecurityThemes.moneySecureMode.map({ $0 == .visible ? visible : none })
    }
    // MARK: -
    // MARK: 步驟五 釋放可全域綁定物件腳
    static let moneyVisibleOrNotVisible: Observable<Bool> = WalletSecurityThemes.bindVisibleOrNotStyle(visible:false, none: true)
    static let stringVisibleOrNotVisible: Observable<Bool> = WalletSecurityThemes.bindVisibleOrNotStyle(visible:true, none: false)
}
