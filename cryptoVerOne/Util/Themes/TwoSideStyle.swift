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
    let moneySecureStyle: BehaviorRelay<SecureStyle> = {
        return BehaviorRelay<SecureStyle>(value: .visible)
    }()
    func acceptiMoneySecureStyle(_ style: SecureStyle) {
        if moneySecureStyle.value == .visible {
            moneySecureStyle.accept(.nonVisible)
        } else {
            moneySecureStyle.accept(.visible)
        }
    }
    let interFaceStyle: BehaviorRelay<InterFaceStyle> = {
        return BehaviorRelay<InterFaceStyle>(value: checkTime())
    }()
    func acceptiInterFaceStyle(_ style: InterFaceStyle) {
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
