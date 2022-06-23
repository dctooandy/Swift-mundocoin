//
//  StyleThemes.swift
//  cryptoVerOne
//
//  Created by BBk on 6/23/22.
//

import Foundation
import UIKit
import Foundation
import RxSwift
import RxCocoa

class StyleThemes {
    static var share = StyleThemes()
    // MARK: -
    // MARK: 步驟一 內部宣告可監聽狀態
    // 變換取款成功頁面上方狀態
    private let topViewStatusStyle: BehaviorRelay<DetailType> = {
        return BehaviorRelay<DetailType>(value: .done)
    }()
    // MARK: -
    // MARK: 步驟二 釋放可設定狀態
    func acceptTopViewStatusStyle(_ style: DetailType) {
        topViewStatusStyle.accept(style)
    }
    // MARK: -
    // MARK: 步驟三 內部宣告可綁定名稱
    // 綁定取款成功頁面 上方狀態View
    private static let topViewMode = StyleThemes.share.topViewStatusStyle.asObservable()
    // MARK: -
    // MARK: 步驟四 內部宣告可綁定參數
    private static func bindDetailViewTopIcon<T>(success: T , failed: T) -> Observable<UIImage>{
        return topViewMode.map({($0 == .done || $0 == .pending || $0 == .processing) ? UIImage(named: "icon-done")!:UIImage(named: "icon-error")!})
    }
    // MARK: -
    // MARK: 步驟五 釋放可全域綁定物件腳
    static let topImageIconType : Observable<UIImage> = bindDetailViewTopIcon(success: DetailType.done, failed: DetailType.failed)

}
