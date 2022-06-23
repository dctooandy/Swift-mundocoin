//
//  WhiteListThemes.swift
//  cryptoVerOne
//
//  Created by BBk on 6/23/22.
//


import Foundation
import UIKit
import Foundation
import RxSwift
import RxCocoa

class WhiteListThemes {
    static var share = WhiteListThemes()
    // MARK: -
    // MARK: 步驟一 內部宣告可監聽狀態
    // 變換白名單圖片狀態
    private let topViewWhiteListImageStyle: BehaviorRelay<WhiteListStyle> = {
        return BehaviorRelay<WhiteListStyle>(value: .whiteListOn)
    }()
    // MARK: -
    // MARK: 步驟二 釋放可設定狀態
    func acceptWhiteListTopImageStyle(_ style: WhiteListStyle) {
        topViewWhiteListImageStyle.accept(style)
    }
    // MARK: -
    // MARK: 步驟三 內部宣告可綁定名稱
    // 綁定白名單上方圖片狀態
    private static let topWhiteListImageMode = WhiteListThemes.share.topViewWhiteListImageStyle.asObservable()
    // MARK: -
    // MARK: 步驟四 內部宣告可綁定參數
    private static func bindWhiteListTopIcon<T>(isON: T , isOff: T) -> Observable<UIImage>{
        return WhiteListThemes.topWhiteListImageMode.map({($0 == .whiteListOn) ? UIImage(named: "icon-Chield_check")!:UIImage(named: "icon-Chield")!})
    }
    private static func bindWhiteListSwitchAlpha<T>(isOn:T , isOff:T) -> Observable<CGFloat>{
        return WhiteListThemes.topWhiteListImageMode.map({($0 == .whiteListOn) ? 1.0 : 0.5})
    }
    private static func bindWhiteListSwitchEnable<T>(isOn:T , isOff:T) -> Observable<Bool>{
        return WhiteListThemes.topWhiteListImageMode.map({($0 == .whiteListOn) ? true : false})
    }
    // MARK: -
    // MARK: 步驟五 釋放可全域綁定物件腳
    static let topWhiteListImageIconType : Observable<UIImage> =
    WhiteListThemes.bindWhiteListTopIcon(isON: WhiteListStyle.whiteListOn, isOff: WhiteListStyle.whiteListOff)
    
    static let whiteListSwitchAlpha : Observable<CGFloat> =
    WhiteListThemes.bindWhiteListSwitchAlpha(isOn: WhiteListStyle.whiteListOn, isOff: WhiteListStyle.whiteListOff)
    
    static let whiteListSwitchEnable : Observable<Bool> =
    WhiteListThemes.bindWhiteListSwitchEnable(isOn: WhiteListStyle.whiteListOn, isOff: WhiteListStyle.whiteListOff)

}
