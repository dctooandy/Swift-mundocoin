//
//  RegexHelper.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation


struct RegexHelper {
    
    enum Pattern {
        case account
        case delegateNumber
        case delegateName
        case mail
        case realName
        case countryName
        case password
        case phone
        case otp
        case coinAddress
        case moneyAmount
        case onlyNumber
        
        var valid:String {
            switch  self {
            case .account:
                return "^[0-9a-zA-Z_]{5,15}+$"
            case .delegateNumber:
                return "^[0-9a-zA-Z_]{1,15}+$"
            case .delegateName:
                return "^[0-9a-zA-Z_\\u4E00-\\u9FA5 ]{1,30}+$"
            case .mail:
                return "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            case .realName:
                return "^[\\u4E00-\\u9FA5]{1,31}+$"
            case .countryName:
                return "^[\\u4E00-\\u9FA5]{1,31}+$"
            case .password:
                return "^[A-Za-z0-9_\\.-^%&',;=?$!+|-~#()*]{8,20}+$"
            case .phone:
                return "^((13|14|15|16|18|19)\\d{9}){1}$"
            case .otp:
                return "^\\d{6}$"
            case .coinAddress:
                return "^((T)[0-9a-zA-Z_]{33}){1}$"
//            case .coinAddress:
//                return "^[0-9a-zA-Z_\\.-]{1,50}+$"
            case .moneyAmount:
                return "^[0-9\\.]{1,15}+$"
            case .onlyNumber:
                return "^[0-9]"
            }
        }
        var invalid:[String] {
            switch  self {
            case .account,.delegateName:
                return ["^(\\..)+$","^(.\\..)+$"]
            case .password:
                return ["^(\\..)+$","^(.\\..)+$"]
//                return ["^\\bPASSWORD\\b","^\\bPassword\\b","^\\bPASSW0RD\\b","^\\bpassw0rd\\b","^\\bpasswd\\b","^\\bPassword\\b","^(\\..)+$",
//                "^(.\\..)+$"]
            default:
                return [""]
            }
        }
        
        
    }
    
    let regex: NSRegularExpression
    static let phonePattern = "^((13|14|15|16|18|19)\\d{9}){1}$"
    static let mailPattern = "^[a-z0-9\\.-_]+@[a-z0-9-]+(\\.[a-z0-9-]+)+$"
    
    
    
    
    init(_ pattern: String ) throws {
        try regex = NSRegularExpression(pattern: pattern,
                                        options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        let matches = regex.matches(in: input,
                                    options: [],
                                    range: NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
    
    static func match(pattern:Pattern , input: String) -> Bool {
        for inValidPattern in pattern.invalid {
            if let regex = try? RegexHelper(inValidPattern) {
                if regex.match(input: input) {
                    return false
                }
            }
        }
        if let regex = try? RegexHelper(pattern.valid) {
            return regex.match(input: input)
        }
        return false
    }
}
