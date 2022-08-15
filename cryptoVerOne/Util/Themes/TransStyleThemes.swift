//
//  TransStyleThemes.swift
//  cryptoVerOne
//
//  Created by BBk on 6/23/22.
//

import Foundation
import UIKit
import Foundation
import RxSwift
import RxCocoa

class TransStyleThemes {
    static var share = TransStyleThemes()
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
    private static let topViewMode = TransStyleThemes.share.topViewStatusStyle.asObservable()
    // MARK: -
    // MARK: 步驟四 內部宣告可綁定參數
    func checkDetailViewTopIcon(data: DetailType) -> Bool {
        return data == .done || data == .innerDone || data == .pending || data == .processing
    }
    private static func bindDetailViewTopIcon<T>(success: T , failed: T) -> Observable<UIImage> {
        let doneImage = UIImage(named: "icon-done")!
        let errorImage = UIImage(named: "icon-error")!
        return topViewMode.map({ TransStyleThemes.share.checkDetailViewTopIcon(data: $0) ? doneImage : errorImage } )
    }
    private static func bindDetailViewTopString<T>(success: T , failed: T) -> Observable<String>{
        let doneString = "Your withdrawal request is submitted Successfully."
        let errorString = "Your withdrawal request is submitted failed."
        return topViewMode.map({TransStyleThemes.share.checkDetailViewTopIcon(data: $0) ? doneString : errorString } )
    }
    // 綁定取款成功頁面 下方隱藏物件
    private static func bindDetailListViewHidden<T>(hidden: T , visible : T) -> Observable<Bool>{
        return topViewMode.map({ ($0 == .pending || $0 == .innerDone || $0 == .innerFailed ) ? true : false})
    }
    private static func bindDetailListFeeViewHidden<T>(hidden: T , visible : T) -> Observable<Bool>{
        return topViewMode.map({ ($0 == .pending ) ? true : false})
    }
    // 綁定 pending跟processing 的顯示
    func checkDetailViewProcessingBorderColor(data: DetailType) -> Bool {
        return data == .done || data == .innerDone || data == .pending || data == .failed || data == .innerFailed
    }
    private static func bindDetailViewProcessingBorderColor<T>(noProcessing: T , processing: T) -> Observable<UIColor>{
        return topViewMode.map({ TransStyleThemes.share.checkDetailViewProcessingBorderColor(data: $0) ? UIColor.clear:UIColor(red: 0.381, green: 0.286, blue: 0.967, alpha: 1) })
    }
    private static func bindDetailViewProcessingTextColor<T>(noProcessing: T , processing: T) -> Observable<UIColor>{
        return topViewMode.map({ TransStyleThemes.share.checkDetailViewProcessingBorderColor(data: $0) ? Themes.grayE0E5F2:Themes.gray2B3674 } )
    }
    private static func bindDetailViewCompleteViewHidden<T>(hidden: T , show: T) -> Observable<Bool>{
        return topViewMode.map({($0 == .processing || $0 == .pending ) ? true:false })
    }
    // 綁定TopView 文字顏色
    private static func bindTopViewTextColor<T>(done: T , failed: T) -> Observable<UIColor>{
        return topViewMode.map({($0 == .done || $0 == .innerDone ) ? Themes.green0DC897:Themes.redEE5D50 })
    }
    private static func bindDetailViewTryBtnHidden<T>(hidden: T , show: T) -> Observable<Bool>{
        return topViewMode.map({($0 != .failed || $0 != .innerFailed ) ? true:false })
    }
    private static func bindDetailListTopViewIconName<T>(done: T , failed : T) -> Observable<UIImage>{
        return topViewMode.map({ (($0 == .done || $0 == .innerDone ) ? UIImage(named: "icon-done") : UIImage(named: "icon-error"))!})
    }
    private static func bindDetailListTopViewLabelText<T>(done: T , failed : T) -> Observable<String>{
        return topViewMode.map({ (($0 == .done || $0 == .innerDone ) ? "Completed".localized : "Failed".localized)})
    }
    // MARK: -
    // MARK: 步驟五 釋放可全域綁定物件腳
    static let topImageIconType : Observable<UIImage> = bindDetailViewTopIcon(success: DetailType.done, failed: DetailType.failed)
    static let topLabelStringType : Observable<String> = bindDetailViewTopString(success: DetailType.done, failed: DetailType.failed)
    // 綁定取款成功頁面要不要顯示TXID欄位
    static let txidViewType : Observable<Bool> = bindDetailListViewHidden(hidden: true, visible: false)
    static let feeViewType : Observable<Bool> = bindDetailListFeeViewHidden(hidden: true, visible: false)
    static let processingImageType : Observable<UIColor> = bindDetailViewProcessingBorderColor(noProcessing: DetailType.done, processing: DetailType.processing)
    static let processingLabelType : Observable<UIColor> = bindDetailViewProcessingTextColor(noProcessing: DetailType.done, processing: DetailType.processing)
    static let completeViewType : Observable<Bool> = bindDetailViewCompleteViewHidden(hidden: DetailType.pending, show: DetailType.done)
    // 綁定TopViewLabel文字顏色
    static let topViewLabelTextColor : Observable<UIColor> = bindTopViewTextColor(done: true, failed: false)
    // 綁定取款成功頁面 要不要顯示try again Btn
    static let tryAgainBtnHiddenType : Observable<Bool> = bindDetailViewTryBtnHidden(hidden: true, show: false)
    // 綁定TopViewIcon樣式
    static let topViewIconType : Observable<UIImage> = bindDetailListTopViewIconName(done: true, failed: false)
    // 綁定TopViewLabel文字
    static let topViewLabelText : Observable<String> = bindDetailListTopViewLabelText(done: true, failed: false)
}
