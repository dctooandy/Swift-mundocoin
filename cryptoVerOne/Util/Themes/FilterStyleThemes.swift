//
//  FilterStyleThemes.swift
//  cryptoVerOne
//
//  Created by BBk on 6/23/22.


import Foundation
import UIKit
import Foundation
import RxSwift
import RxCocoa

class FilterStyleThemes {
    static var share = FilterStyleThemes()
    // MARK: -
    // MARK: 步驟一 內部宣告可監聽狀態
    // 變換sheet高度
    private let sheetHeightStyle: BehaviorRelay<TransactionShowMode> = {
        return BehaviorRelay<TransactionShowMode>(value: .withdrawals)
    }()
    // MARK: -
    // MARK: 步驟二 釋放可設定狀態
    func acceptSheetHeightStyle(_ style: TransactionShowMode) {
        sheetHeightStyle.accept(style)
    }
    // MARK: -
    // MARK: 步驟三 內部宣告可綁定名稱
    // 改變 sheet height
    private static let heightForFilterMode = FilterStyleThemes.share.sheetHeightStyle.asObservable()
    // MARK: -
    // MARK: 步驟四 內部宣告可綁定參數
    private static func bindSheetHeight<T>(isDeposits: T , isWithdrawals: T) -> Observable<CGFloat>{
        var disHeight = 0.0
        if KeychainManager.share.getMundoCoinNetworkMethodEnable() == true
        {
            disHeight = 66.0
        }
        return FilterStyleThemes.heightForFilterMode.map({($0 == .deposits || $0 == .all) ?
            400.0 + disHeight + Views.bottomOffset :
            467.0 + disHeight + Views.bottomOffset})

    }
    private static func bindStatusHidden<T>(isDeposits: T , isWithdrawals: T) -> Observable<Bool>{
        return FilterStyleThemes.heightForFilterMode.map({($0 == .deposits || $0 == .all) ?
            true :
            false})
    }
    // MARK: -
    // MARK: 步驟五 釋放可全域綁定物件腳
    static let sheetHeightType : Observable<CGFloat> =
    FilterStyleThemes.bindSheetHeight(isDeposits: TransactionShowMode.deposits , isWithdrawals: TransactionShowMode.withdrawals)
    static let statusViewHiddenType : Observable<Bool> =
    FilterStyleThemes.bindStatusHidden(isDeposits: TransactionShowMode.deposits , isWithdrawals: TransactionShowMode.withdrawals)
}
