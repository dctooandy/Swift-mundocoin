//
//  TwoSideStyle.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/17.
//

import Foundation
import RxSwift
import RxCocoa

class TwoSideStyle {
    enum InterFaceStyle {
        case light, dark
    }
    enum SecureStyle {
        case visible, nonVisible
    }
 
    
    static var share = TwoSideStyle()
    
    // 變換白名單圖片狀態
    let topViewWhiteListImageStyle: BehaviorRelay<WhiteListStyle> = {
        return BehaviorRelay<WhiteListStyle>(value: .whiteListOn)
    }()
    func acceptWhiteListTopImageStyle(_ style: WhiteListStyle) {
        topViewWhiteListImageStyle.accept(style)
    }
    // 變換取款成功頁面上方狀態
    let topViewStatusStyle: BehaviorRelay<DetailType> = {
        return BehaviorRelay<DetailType>(value: .done)
    }()
    func acceptTopViewStatusStyle(_ style: DetailType) {
        topViewStatusStyle.accept(style)
    }
    // 開啟關閉金額
    let moneySecureStyle: BehaviorRelay<SecureStyle> = {
        return BehaviorRelay<SecureStyle>(value: .visible)
    }()
    func acceptMoneySecureStyle(_ style: SecureStyle) {
        if moneySecureStyle.value == .visible {
            moneySecureStyle.accept(.nonVisible)
        } else {
            moneySecureStyle.accept(.visible)
        }
    }
    let interFaceStyle: BehaviorRelay<InterFaceStyle> = {
        return BehaviorRelay<InterFaceStyle>(value: checkTime())
    }()
    func acceptInterFaceStyle(_ style: InterFaceStyle) {
//        if interFaceStyle.value == .light {
//            interFaceStyle.accept(.dark)
//        } else {
            interFaceStyle.accept(.light)
//        }
    }
    
    func updateStyle() {
        let currentStyle = TwoSideStyle.checkTime()
        switch currentStyle {
        case .light:
            if interFaceStyle.value != .light {
                interFaceStyle.accept(.light)
            }
        case .dark:
            if interFaceStyle.value != .dark {
                interFaceStyle.accept(.dark)
            }
        }
    }
    
    static func checkTime() -> InterFaceStyle  {
        let componets = Calendar.current.dateComponents([.hour], from: Date())
        let currentHour = componets.hour!
        if currentHour >= 6 && currentHour < 18 {
            print ("白天")
            return .light
        } else {
            print ("晚上")
            return .dark
        }
    }
}
