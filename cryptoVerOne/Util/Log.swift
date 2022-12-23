//
//  Log.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import SwiftyBeaver

//Log.v("not so important")  // prio 1, VERBOSE in silver
//Log.d("something to debug")  // prio 2, DEBUG in green
//Log.i("a nice information")   // prio 3, INFO in blue
//Log.w("oh no, that won’t be good")  // prio 4, WARNING in yellow
//Log.e("ouch, an error did occur!")  // prio 5, ERROR in red

class Log {
    let log = SwiftyBeaver.self
    private let console = ConsoleDestination()
    private let file = FileDestination()
    static let share = Log()
    
    init() {
        console.format = "\n$DHH:mm:ss$d $M" //$L
        log.addDestination(console)
        log.addDestination(file)
    }
    
    static func v(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.verbose("🍀 \(path)-\(function) L:\(line) 🍀\n🍀🍀 \n\(message())\n🍀🍀")
    }
    
    static func d(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.debug("🐛 \(path)-\(function) L:\(line) 🐛\n🐛🐛 \n\(message())\n🐛🐛")
    }
    
    static func i(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.info("ℹ️ \(path)-\(function) L:\(line) ℹ️\nℹ️ℹ️ \n\(message())\nℹ️ℹ️")
    }
    static func socket(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.info("♻️ \(path)-\(function) L:\(line) ♻️\n♻️♻️ \(message()) ♻️♻️")
    }
    
    static func w(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.warning("⚠️ \(path)-\(function) L:\(line) ⚠️\n⚠️⚠️ \n\(message())\n⚠️⚠️")
    }
    
    static func e(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.error("🆘 \(path)-\(function) L:\(line) 🆘\n🆘🆘 \n\(message())\n🆘🆘")
    }
    
    static func errorAndCrash(_ message:@autoclosure () -> Any, _
                              file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) -> Never {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.error("🆘 \(path)-\(function) L:\(line) 🆘\n🆘🆘 \n\(message())\n🆘🆘")
        fatalError()
    }
}
