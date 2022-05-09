//
//  AppVersionDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation

class AppVersionDto: Codable, Equatable {
    static var didFetch: Bool = false
    static var share: AppVersionDto? = nil
    let appVersionVersion: String
    let appVersionForceUpdate: ValueOptionBoolDto?
    let appVersionFileLocation: String
    let appVersionTitle: String
    let appVersionContent: String
    static func == (lhs: AppVersionDto, rhs: AppVersionDto) -> Bool {
        return lhs.appVersionVersion == rhs.appVersionVersion
    }
}
