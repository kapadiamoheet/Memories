//
//  Logger.swift

import Foundation
import SwiftyBeaver

var logger: SwiftyBeaver.Type!

typealias LogMessage = ()->Any

class Logger {
    
    public enum Level: Int {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
    }
    
    public enum ModuleType: String {
        case webService = "WebService:" //debug
        case userAction = "User Action:" //verbose
        case enterScope = "Enter Scope:" // verbose
        case exitScope = "Exit Scope:" //verbose
        case generalError = "General Error:" //debug
        case printValue = "Value:" //debug
        case appLifeCycle = "Application Cycle:" //verbose
    }
    
    // full datetime, file, function, line, colored log level and message
    static let logFormat = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $N.$F():$l $C$L$c: $M"
    
    class func configure() {
        //initialize...
        logger = SwiftyBeaver.self
        
        let console = ConsoleDestination()
        console.format = logFormat
        logger.addDestination(console)
        
        let file = FileDestination()
        
        file.format = logFormat
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileName = AppInfo.name + ".log"
            let fileURL = url.appendingPathComponent(fileName)
            print("Log File Path:\(fileURL)")
            file.logFileURL = fileURL
        }
        
        //set minimum log level to log
        #if DEBUG
          file.minLevel = .verbose
        #else
          file.minLevel = .warning
        #endif
        
        //set thread for logging
        #if DEBUG
         file.asynchronously = true
        #endif
        
        logger.addDestination(file)
    }
    
    class func log(level:Level, type: ModuleType, message: @autoclosure ()->Any? = nil,
                   _ file: String = #file, _ function: String = #function, line: Int = #line,
                   context: Any? = nil) {
        
        var msg = type.rawValue + (message() != nil ? " " + "\(message()!)" : "")
        
        if let cxt = context {
            msg += "\(cxt)"
        }
        
        switch level {
        case .verbose:
            logger.verbose(msg, file, function, line: line, context:context)
        case .debug:
            logger.debug(msg, file, function, line: line, context:context)
        case .info:
            logger.info(msg, file, function, line: line, context:context)
        case .warning:
            logger.warning(msg, file, function, line: line, context:context)
        case .error:
            logger.error(msg, file, function, line: line, context:context)
        }
        
    }
}
