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
//Log.w("oh no, that wonโt be good")  // prio 4, WARNING in yellow
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
        Log.share.log.verbose("๐ \(path)-\(function) L:\(line) ๐\n๐๐บ\n\(message())\n๐บ๐")
    }
    
    static func d(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.debug("๐ \(path)-\(function) L:\(line) ๐\n๐๐บ \n\(message())\n๐บ๐")
    }
    
    static func i(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.info("โน๏ธ \(path)-\(function) L:\(line) โน๏ธ\nโน๏ธ๐บ \n\(message())\n๐บโน๏ธ")
    }
    static func socket(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.info("โป๏ธ \(path)-\(function) L:\(line) โป๏ธ\n๐\(message()) ๐\nโป๏ธ\(path)-end โป๏ธ")
    }
    
    static func w(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.warning("โ?๏ธ \(path)-\(function) L:\(line) โ?๏ธ\nโ?๏ธ๐ \n\(message())\n๐โ?๏ธ")
    }
    
    static func e(_ message:@autoclosure () -> Any, _
                  file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.error("๐ \(path)-\(function) L:\(line) ๐\n๐โก๏ธ \n\(message())\nโก๏ธ๐")
    }
    
    static func errorAndCrash(_ message:@autoclosure () -> Any, _
                              file:String = #file, _ function:String = #function, line:Int = #line, context:Any? = nil) -> Never {
        let path = (file as NSString).lastPathComponent.split(separator: ".").first!
        Log.share.log.error("๐ \(path)-\(function) L:\(line) ๐\n๐โก๏ธ \n\(message())\nโก๏ธ๐")
        fatalError()
    }
}
