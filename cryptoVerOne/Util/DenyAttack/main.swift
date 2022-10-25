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
        super.sendEvent(event)
//        print("Event sent:\(event)")
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
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    nil,
    NSStringFromClass(AppDelegate.self)
)
#endif



