//
//  UserStatus.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation

class UserStatus {
    static let share = UserStatus()
    var isLogin:Bool {
        return !KeychainManager.share.getToken().isEmpty
    }
}
