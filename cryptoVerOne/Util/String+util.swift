//
//  String+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/5.
//

import Foundation
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    func localized(withTableName tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: self)
    }
}
