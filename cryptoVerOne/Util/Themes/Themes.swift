//
//  Themes.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class Themes {
    
    static let plkMode = TwoSideStyle.share.interFaceStyle.asObservable()
    static func bindChooseOrNotStyle<T>(light: T, dark: T) -> Observable<T> {
        return Themes.plkMode.map({ $0 == .light ? light : dark })
    }
    // 綁定取款成功頁面 上方狀態View
    static let topViewMode = TwoSideStyle.share.topViewStatusStyle.asObservable()
    static func bindDetailViewTopIcon<T>(success: T , failed: T) -> Observable<UIImage>{
        return Themes.topViewMode.map({($0 == .done || $0 == .pending || $0 == .processing) ? UIImage(named: "icon-done")!:UIImage(named: "icon-error")!})
    }
    static func bindDetailViewTopString<T>(success: T , failed: T) -> Observable<String>{
        return Themes.topViewMode.map({($0 == .done || $0 == .pending || $0 == .processing) ? "Your withdrawal request is submitted Successfully.":"Your withdrawal request is submitted failed." })
    }
    // 綁定 pending跟processing 的顯示
    static func bindDetailViewProcessingBorderColor<T>(noProcessing: T , processing: T) -> Observable<UIColor>{
        return Themes.topViewMode.map({($0 == .done || $0 == .pending || $0 == .failed) ? UIColor.clear:UIColor(red: 0.381, green: 0.286, blue: 0.967, alpha: 1) })
    }
    static func bindDetailViewProcessingTextColor<T>(noProcessing: T , processing: T) -> Observable<UIColor>{
        return Themes.topViewMode.map({($0 == .done || $0 == .pending || $0 == .failed) ? Themes.grayE0E5F2:Themes.blue2B3674 })
    }
    static func bindDetailViewCompleteViewHidden<T>(hidden: T , show: T) -> Observable<Bool>{
        return Themes.topViewMode.map({($0 == .processing || $0 == .pending || $0 == .failed) ? true:false })
    }
    static let processingImageType : Observable<UIColor> = Themes.bindDetailViewProcessingBorderColor(noProcessing: DetailType.done, processing: DetailType.processing)
    static let processingLabelType : Observable<UIColor> = Themes.bindDetailViewProcessingTextColor(noProcessing: DetailType.done, processing: DetailType.processing)
    static let completeViewType : Observable<Bool> = Themes.bindDetailViewCompleteViewHidden(hidden: DetailType.pending, show: DetailType.done)
    
    // 綁定取款成功頁面 下方隱藏物件
    static func bindDetailListViewHidden<T>(hidden: T , visible : T) -> Observable<Bool>{
        return Themes.topViewMode.map({ ($0 == .pending || $0 == .failed ) ? true : false})
    }
    static let topImageIconType : Observable<UIImage> = Themes.bindDetailViewTopIcon(success: DetailType.done, failed: DetailType.failed)
    static let topLabelStringType : Observable<String> = Themes.bindDetailViewTopString(success: DetailType.done, failed: DetailType.failed)
    // 綁定取款成功頁面要不要顯示TXID欄位
    static let txidViewType : Observable<Bool> = Themes.bindDetailListViewHidden(hidden: true, visible: false)
    
    
    // 綁定 輸入框typing狀態的border
    static let moneySecureMode = TwoSideStyle.share.moneySecureStyle.asObservable()
    static func bindVisibleOrNotStyle<T>(visible: T, none: T) -> Observable<T> {
        return Themes.moneySecureMode.map({ $0 == .visible ? visible : none })
    }
    static let moneyVisibleOrNotVisible: Observable<Bool> = Themes.bindVisibleOrNotStyle(visible:false, none: true)
    static let stringVisibleOrNotVisible: Observable<Bool> = Themes.bindVisibleOrNotStyle(visible:true, none: false)
    
    
    
    
    static let chooseOrNotChoose: Observable<UIColor> = Themes.bindChooseOrNotStyle(
        light: Themes.grayA3AED0, dark: Themes.grayE0E5F2)
    
    static let passwordInvalidLabelHeight = 32.0
    static let defaultInvalidLabelHeight = 15.0
    static let inputViewDefaultHeight = 85.0 + Themes.defaultInvalidLabelHeight
    static let inputViewPasswordHeight = 85.0 + Themes.passwordInvalidLabelHeight
    
    static let grayA3AED0 = UIColor(rgb: 0xA3AED0)
    static let grayE0E5F2 = UIColor(rgb: 0xE0E5F2)
    static let grayCCD2E3 = UIColor(rgb: 0xCCD2E3)
    static let gray707EAE = UIColor(rgb: 0x707EAE)
    static let gray1CD0C5 = UIColor(rgb: 0x1CD0C5)
    static let grayF4F7FE = UIColor(rgb: 0xF4F7FE)
    static let blue2B3674 = UIColor(rgb: 0x2B3674)
    static let purple6149F6 = UIColor(rgb: 0x6149F6)
    static let redEE5D50 = UIColor(rgb: 0xEE5D50)
    
    
    static let primaryLight =  UIColor(rgb: 0xc2aaf2)
    static let primaryBase = UIColor(rgb: 0x8e73da)
    static let primaryDark = UIColor(rgb: 0x6b49aa)
    static let mediumPurple  = UIColor(rgb: 0xE7E4F6)
    static let secondaryBlue = UIColor(rgb: 0x20a0ff)
    
    static let textFieldDisableColor = UIColor(rgb: 0xeff2f7)
    static let saveMoneyLayerColor = UIColor(rgb: 0x43959A)
    static let cashOutMoneyLayerColor = UIColor(rgb: 0xBD2D2C)
    static let transMoneyLayerColor = UIColor(rgb: 0x306CD2)
    static let trueGreenLayerColor = UIColor(rgb: 0x67c23a)
    static let falseRedLayerColor = UIColor(rgb: 0xfa5555)
    static let lineBlueColor = UIColor(rgb: 0x0250B3)
    static let darkBlueLayer = UIColor(rgb: 0x012460)
    static let deepDarkBlue = UIColor(rgb:0x001E46)
    static let lightBlueLayer = UIColor(rgb: 0x1790FF)
    static let grayLayer = UIColor(rgb: 0xD9D9D9)
    static let leadingBlueLayer = UIColor(rgb: 0x204FAD)
    static let middleBlueLayer = UIColor(rgb: 0x2D6AC0)
    static let traillingBlueLayer = UIColor(rgb: 0x3A85D3)
    static let hintCellBackgroundBlue = UIColor(rgb:0xE2F6FF)
    static let placeHolderPrimyGary = UIColor(rgb:0xBDBDBD)
    static let placeHolderDarkGary = UIColor(rgb:0x8D8D8D)
    static let placeHolderlightGary = UIColor(rgb:0xEFEFEF)
    static let searchFieldBackground = UIColor(rgb: 0x011D4D)
    static let sectionBackground = UIColor(rgb: 0xF5F5F5)
    static let gradientStartBlue = UIColor(rgb: 0x002766)
    static let gradientEndBlue = UIColor(rgb: 0x001332)
    static let gradientCenterYellow = UIColor(rgb: 0xFADB14)
    static let labelBlue = UIColor(rgb: 0x438DF7)
    static let infoLineLabelBlue = UIColor(rgb: 0x5B9CF8)
    static let titleLabelBlack = UIColor(rgb: 0x262626)
    static let timeLabelBlack = UIColor(rgb: 0x8d8d8d)
    static let cellSelected = UIColor(rgb: 0xf5faff)
    static let btnBackgroundBlue = UIColor(rgb: 0x0050b3)
    static let menuSelected = UIColor(rgb: 0x6C609D)
    static let primeBackground = UIColor(rgb: 0xffffff)
    static let primeBtnPupple = UIColor(rgb: 0x322260)
    static let secondaryOrange = UIColor(rgb: 0xf87b09)
    static let grayDarker = UIColor(rgb: 0x3b465c)
    static let badgeBackgroundRed = UIColor(rgb: 0xff4949)
    static let grayBase = UIColor(rgb: 0x939fb8)
    static let grayLight = UIColor(rgb: 0xbfc7d9)
    static let secondaryYellow = UIColor(rgb: 0xf7ba2a)
    
    // Gradient
    static let gradientStartOrange = UIColor(rgb: 0xffad00)
    static let gradientEndOrange = UIColor(rgb: 0xf96d00)
    static let secondaryGreen = UIColor(rgb: 0x13ce66)
    static let gradientEndGreen = UIColor(rgb: 0x2be99f)
    static let gradientStartPuple = UIColor(rgb: 0x7b7cf9)
    static let gradientEndPuple = UIColor(rgb: 0x7c69f8)
    
    //border
    static let grayLightest = UIColor(rgb: 0xf2f4f7)
    
    
    static let imagePlaceHolder = UIImage(color: Themes.placeHolderPrimyGary, size: CGSize(width: 800, height: 800))
    
    //BottomSheet
    static let grayDarkest = UIColor(rgb: 0x1a2233)
    static let grayDark = UIColor(rgb: 0x6c7891)
    
    static let grayLightDarker = UIColor(rgb: 0x656565)
    static let grayBlack = UIColor(rgb: 0x191919)
    static let secondaryRed = UIColor(rgb: 0xff4949)
    
    // from betlead sport
    static let darkGrey =  UIColor(rgb: 0x696969)
    static let peachGray =  UIColor(rgb: 0xb970e5)
    
    static let emptyImage = UIImage()
    
    static func applyNavigationBar(navBar:UINavigationBar?, isTranslucent:Bool = false) {
        guard let navBar = navBar else {
            return
        }
        navBar.isTranslucent = isTranslucent
        navBar.tintColor = .white
        navBar.barTintColor = .white
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navBar.shadowImage = emptyImage
        navBar.setBackgroundImage(UIImage(named: "navigation-bg") , for: .default)
    }
    
    static func applyNavigationBar(navBar:UINavigationBar?, color:UIColor) {
        guard let navBar = navBar else {
            return
        }
        navBar.setBackgroundImage(UIImage(color:color), for:.default)
    }
    
    static func applyNavigationBarClear(navBar:UINavigationBar?, alpha:CGFloat, tinColor:UIColor) {
        guard let navBar = navBar else {
            return
        }
        navBar.isTranslucent = true
        navBar.shadowImage = emptyImage
        var red:CGFloat = 0.0;
        var green:CGFloat = 0.0;
        var blue:CGFloat = 0.0;
        var a:CGFloat = 0.0
        tinColor.getRed(&red, green:&green, blue:&blue, alpha:&a)
        navBar.setBackgroundImage(UIImage(color:UIColor(red:red, green:green, blue:blue, alpha:alpha)), for:.default)
    }
    static func createGradientBgView() -> UIImageView {
        return UIImageView(image: UIImage(named: "navigation-bg") )
    }
}





extension UIColor {
    
//    convenience init(rgb: Int) {
//        self.init(
//            red: (rgb >> 16) & 0xFF,
//            green: (rgb >> 8) & 0xFF,
//            blue: rgb & 0xFF
//        )
//    }
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: alpha
        )
    }
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
//    convenience init(rgb: Int, a: CGFloat = 1.0) {
//        self.init(
//            red: (rgb >> 16) & 0xFF,
//            green: (rgb >> 8) & 0xFF,
//            blue: rgb & 0xFF,
//            a: a
//        )
//    }
    
}
