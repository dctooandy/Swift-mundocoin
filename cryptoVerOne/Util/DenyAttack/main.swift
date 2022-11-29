//
//  main.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/10/25.
//

import Foundation
import UIKit
class MyApplication: UIApplication {
    override func sendEvent(_ event: UIEvent) {
        // 處理統一的邏輯
//        print("來自UIApplication 的 Event:\(event)")
        super.sendEvent(event)
    }
    override func sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool {
        // 處理統一的邏輯
//        print("來自UIApplication 的 Action:\(String(describing: event))")
        return super.sendAction(action, to: target, from: sender, for: event)
    }
}
#if Mundo_PRO || Mundo_STAGE || Approval_PRO || Approval_STAGE
disable_gdb()
plokij()
UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(MyApplication.self),
    NSStringFromClass(AppDelegate.self)
)
#else
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(AppDelegate.self)
)
#endif



