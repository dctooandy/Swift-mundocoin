//
//  UITableViewCell+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/10.
//

import Foundation
import UIKit

extension UITableView {
    func dequeueCell<T>(type: T.Type, indexPath: IndexPath) -> T {
        let cell = self.dequeueReusableCell(withIdentifier: NSStringFromClass(type as! AnyClass),
                                            for: indexPath) as! T
        return cell
    }
    
    func dequeueHeaderFooter<T>(type: T.Type) -> T {
        let headerFooter = self.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(type as! AnyClass)) as! T
        return headerFooter
    }
    
    func registerCell(type: AnyClass) {
        self.register(type, forCellReuseIdentifier: NSStringFromClass(type))
    }
    
    func registerHeaderFooter(type: AnyClass) {
        self.register(type, forHeaderFooterViewReuseIdentifier: NSStringFromClass(type))
    }
    func registerXibCell(type: AnyClass) {
        self.register(UINib(nibName: "\(type)", bundle: nil), forCellReuseIdentifier: NSStringFromClass(type))
    }
    func registerXibHeader(type: AnyClass) {
        self.register(UINib(nibName: "\(type)", bundle: nil), forHeaderFooterViewReuseIdentifier: NSStringFromClass(type))
    }
    
}
