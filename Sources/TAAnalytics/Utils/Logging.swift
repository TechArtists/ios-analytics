//
//  Logging.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 03.02.2025.
//

import OSLog

typealias TALogger = TAAnalyticsLogger

public struct TAAnalyticsLogger {
    
    public typealias LogHandler = (_ message: String, _ level: OSLogType) -> Void
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "analytics")
    
    private static let defaultHandler: LogHandler = { message, level in
        logger.log(level: level, "\(message)")
    }
    
    public static var activeLogHandler: LogHandler = defaultHandler
    
    public static func log(_ message: String, level: OSLogType) {
        activeLogHandler(message, level)
    }
}
