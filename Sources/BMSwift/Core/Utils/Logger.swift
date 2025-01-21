#if canImport(SwiftUI) && os(iOS)
import Foundation
import OSLog

/// Logging levels for the application
public enum LogLevel: String {
    case debug = "🔍"
    case info = "ℹ️"
    case warning = "⚠️"
    case error = "❌"
    case critical = "🚨"
}

/// Protocol defining logging functionality
public protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

/// Main logger implementation for BMSwift
public final class Logger: LoggerProtocol {
    public static let shared = Logger()
    
    private let logger: os.Logger
    private let isDebug: Bool
    
    private init() {
        self.logger = os.Logger(subsystem: "com.bmswift", category: "default")
        #if DEBUG
        self.isDebug = true
        #else
        self.isDebug = false
        #endif
    }
    
    public func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(function) - \(message)"
        
        switch level {
        case .debug:
            if isDebug {
                logger.debug("\(logMessage)")
                print(logMessage)
            }
        case .info:
            logger.info("\(logMessage)")
            if isDebug { print(logMessage) }
        case .warning:
            logger.warning("\(logMessage)")
            if isDebug { print(logMessage) }
        case .error:
            logger.error("\(logMessage)")
            if isDebug { print(logMessage) }
        case .critical:
            logger.critical("\(logMessage)")
            if isDebug { print(logMessage) }
        }
    }
}

/// Convenience functions for logging
public func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(message, level: .debug, file: file, function: function, line: line)
}

public func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(message, level: .info, file: file, function: function, line: line)
}

public func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(message, level: .warning, file: file, function: function, line: line)
}

public func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(message, level: .error, file: file, function: function, line: line)
}

public func logCritical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(message, level: .critical, file: file, function: function, line: line)
}
#endif
