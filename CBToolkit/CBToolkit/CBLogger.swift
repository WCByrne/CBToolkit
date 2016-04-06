//
//  CBLogger.swift
//  CBToolkit
//
//  Created by Wesley Byrne on 4/6/16.
//  Copyright © 2016 WCBMedia. All rights reserved.
//

import Foundation

public class CBLogger {
    
    public enum LogLevel: Int {
        case Verbose = 0
        case Debug = 1
        case Info = 2
        case Warning = 3
        case Error = 4
    }
    
    static var destinations = Set<BaseDestination>()
    
    /// returns boolean about success
    public class func addDestination(destination: AnyObject) -> Bool {
        guard let dest = destination as? BaseDestination else {
            print("CBLogger: Failed to add destination")
            return false
        }
        destinations.insert(dest)
        return true
        
    }

    public class func removeDestination(destination: AnyObject) -> Bool {
        guard let dest = destination as? BaseDestination else {
            print("CBLogger: Failed to remove log destination")
            return false
        }
        destinations.remove(dest)
        return true
        
    }
    
    public class func removeAllDestinations() {
        destinations.removeAll()
    }
    
    public class func destinationCount() -> Int {
        return destinations.count
    }
    
    class func threadName() -> String {
        if NSThread.isMainThread() {
            return "main"
        } else {
            if let threadName = NSThread.currentThread().name where !threadName.isEmpty {
                return threadName
            } else if let queueName = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) where !queueName.isEmpty {
                return queueName
            } else {
                return String(format: "%p", NSThread.currentThread())
            }
        }
    }
    
    // MARK: Levels
    public class func verbose(msg: Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(LogLevel.Verbose, msg: msg, thread: threadName(), path: path, function: function, line: line)
    }
    
    public class func debug(msg: Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(LogLevel.Debug, msg: msg, thread: threadName(), path: path, function: function, line: line)
    }
    
    public class func info(msg: Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(LogLevel.Info, msg: msg, thread: threadName(), path: path, function: function, line: line)
    }
    
    public class func warning(msg: Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(LogLevel.Warning, msg: msg, thread: threadName(), path: path, function: function, line: line)
    }
    
    public class func error(msg: Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(LogLevel.Error, msg: msg, thread: threadName(), path: path, function: function, line: line)
    }
    
    /// internal helper which dispatches send to dedicated queue if minLevel is ok
    class func dispatch_send(level: CBLogger.LogLevel, msg: Any, thread: String, path: String, function: String, line: Int) {
        for dest in destinations {
            if let queue = dest.queue {
                if dest.shouldLevelBeLogged(level, path: path, function: function) && dest.queue != nil {
                    // try to convert msg object to String and put it on queue
                    let msgStr = "\(msg)"
                    if msgStr.characters.count > 0 {
                        dispatch_async(queue, {
                            dest.send(level, msg: msgStr, thread: thread, path: path, function: function, line: line)
                        })
                    }
                }
            }
        }
    }
    
    public class func flush(secondTimeout: Int64) -> Bool {
        let grp = dispatch_group_create();
        for dest in destinations {
            if let queue = dest.queue {
                dispatch_group_enter(grp)
                dispatch_async(queue, {
                    dispatch_group_leave(grp)
                })
            }
        }
        let waitUntil = dispatch_time(DISPATCH_TIME_NOW, secondTimeout * 1000000000)
        return dispatch_group_wait(grp, waitUntil) == 0
    }
}







public class BaseDestination: Hashable, Equatable {
    
    //    public var detailOutput = true
    public var colored = true
    
    public var log_File = true
    public var log_Function = false
    public var log_ThreadLevel = 1
    public var log_Date = true
    public var log_maxMessage = -1
    
    public var minLevel = CBLogger.LogLevel.Verbose
    public var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    public var levelNames = LevelName()
    
    public struct LevelName {
        public var Verbose = "VERBOSE"
        public var Debug = "DEBUG"
        public var Info = "INFO"
        public var Warning = "WARNING"
        public var Error = "ERROR"
    }
    
    let formatter = NSDateFormatter()
    
    // For a colored log level word in a logged line
    // XCode RGB colors
    var blue = "fg0,0,255;"
    var green = "fg0,255,0;"
    var yellow = "fg255,255,0;"
    var red = "fg255,0,0;"
    var magenta = "fg255,0,255;"
    var cyan = "fg0,255,255;"
    var silver = "fg200,200,200;"
    var reset = "\u{001b}[;"
    var escape = "\u{001b}["
    
    
    lazy public var hashValue: Int = self.defaultHashValue
    public var defaultHashValue: Int {return 0}
    
    var queue: dispatch_queue_t?
    
    init() {
        let uuid = NSUUID().UUIDString
        let queueLabel = "cblogger-queue-" + uuid
        queue = dispatch_queue_create(queueLabel, nil)
    }
    
    func send(level: CBLogger.LogLevel, msg: String, thread: String, path: String, function: String, line: Int) -> String? {
        var dateStr = ""
        var str = ""
        let levelStr = formattedLevel(level)
        
        dateStr = formattedDate(dateFormat)
        str = formattedMessage(dateStr, levelString: levelStr, msg: msg, thread: thread, path: path,
                               function: function, line: line)
        return str
    }
    
    func formattedDate(dateFormat: String) -> String {
        //formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.dateFormat = dateFormat
        let dateStr = formatter.stringFromDate(NSDate())
        return dateStr
    }
    
    func formattedLevel(level: CBLogger.LogLevel) -> String {
        // optionally wrap the level string in color
        var color = ""
        var levelStr = ""
        
        switch level {
        case CBLogger.LogLevel.Debug:
            color = blue
            levelStr = levelNames.Debug
            
        case CBLogger.LogLevel.Info:
            color = green
            levelStr = levelNames.Info
            
        case CBLogger.LogLevel.Warning:
            color = yellow
            levelStr = levelNames.Warning
            
        case CBLogger.LogLevel.Error:
            color = red
            levelStr = levelNames.Error
            
        default:
            // Verbose is default
            color = silver
            levelStr = levelNames.Verbose
        }
        
        if colored {
            levelStr = escape + color + levelStr + reset
        }
        return levelStr
    }
    
    /// returns the formatted log message
    func formattedMessage(dateString: String, levelString: String, msg: String,
                          thread: String, path: String, function: String, line: Int) -> String {
        // just use the file name of the path and remove suffix
        let file = path.componentsSeparatedByString("/").last!.componentsSeparatedByString(".").first!
        
        var str = ""
        if log_Date && !dateString.isEmpty {
            str += "[\(dateString)] "
        }
        
        if log_ThreadLevel == 1 {
            let t = thread == "main" ? "MAIN" : "ASYN"
            str += "|\(t)| "
        }
        else if log_ThreadLevel > 1 {
            str += "|\(thread)| "
        }
        
        if log_File {
            str += "\(file) @ \(line) "
        }
        if log_Function {
            str += "\(function) "
        }
        
        if self.log_maxMessage > 100 && msg.characters.count > self.log_maxMessage {
            str += "\(levelString): \(msg.substringToIndex(msg.startIndex.advancedBy(self.log_maxMessage)))"
        }
        else {
            str += "\(levelString): \(msg)"
        }
        return str
    }
    
    /// checks if level is at least minLevel or if a minLevel filter for that path does exist
    /// returns boolean and can be used to decide if a message should be logged or not
    func shouldLevelBeLogged(level: CBLogger.LogLevel, path: String, function: String) -> Bool {
        return minLevel.rawValue <= level.rawValue
    }
}

public func == (lhs: BaseDestination, rhs: BaseDestination) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}



public class ConsoleDestination: BaseDestination {
    
    override public var defaultHashValue: Int {return 1}
    
    public override init() {
        super.init()
    }
    
    // print to Xcode Console. uses full base class functionality
    override func send(level: CBLogger.LogLevel, msg: String, thread: String, path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)
        if let str = formattedString {
            print(str)
        }
        return formattedString
    }
}




public class FileDestination: BaseDestination {
    
    public var logFileURL: NSURL
    
    override public var defaultHashValue: Int {return 2}
    let fileManager = NSFileManager.defaultManager()
    
    public init(fileURL: NSURL? = nil) {
        if let url = fileURL {
            logFileURL = url
        }
        else if let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
            logFileURL = url.URLByAppendingPathComponent("swiftybeaver.log", isDirectory: false)
        } else {
            logFileURL = NSURL()
        }
        super.init()
        self.log_maxMessage = 2000
        self.log_Function = true
        
        // bash font color, first value is intensity, second is color
        // see http://bit.ly/1Otu3Zr to learn more
        blue = "0;34m"  // replace first 0 with 1 to make it bold
        green = "0;32m"
        yellow = "0;33m"
        red = "0;31m"
        magenta = "0;35m"
        cyan = "0;36m"
        silver = "0;37m"
        reset = "\u{001b}[0m"
    }
    
    // append to file. uses full base class functionality
    override func send(level: CBLogger.LogLevel, msg: String, thread: String, path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)
        
        if let str = formattedString {
            saveToFile(str, url: logFileURL)
        }
        return formattedString
    }
    
    /// appends a string as line to a file.
    /// returns boolean about success
    func saveToFile(str: String, url: NSURL) -> Bool {
        do {
            if fileManager.fileExistsAtPath(url.path!) == false {
                // create file if not existing
                let line = str + "\n"
                try line.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            } else {
                // append to end of file
                let fileHandle = try NSFileHandle(forWritingToURL: url)
                fileHandle.seekToEndOfFile()
                let line = str + "\n"
                let data = line.dataUsingEncoding(NSUTF8StringEncoding)!
                fileHandle.writeData(data)
                fileHandle.closeFile()
            }
            return true
        } catch let error {
            print("SwiftyBeaver could not write to file \(url). \(error)")
            return false
        }
    }
}

