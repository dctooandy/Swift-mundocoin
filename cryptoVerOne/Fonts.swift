//
//  Fonts.swift
//  betlead
//
//  Created by Victor on 2019/7/23.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit

class Fonts {
    static func pingFangTCRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangTC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func pingFangTCSemibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangTC-Semibold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func pingFangSCSemibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Semibold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func pingFangSCRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func pingFangTCMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangTC-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func pingFangTCLight(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangTC-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func montserratLight(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func sfProLight(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SFPro-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func PlusJakartaSansSemiBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PlusJakartaSans-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func interSemiBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Inter-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
