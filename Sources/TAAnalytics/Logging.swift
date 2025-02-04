//
//  Logging.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 03.02.2025.
//

#if canImport(Logging)
import Logging
#endif

import OSLog

struct TALogger {
    #if canImport(Logging)
    public static let logger = Logger(label: "com.tech-artists.analytics")
    #else
    public static let logger = Logger(subsystem: "", category: "analytics")
    #endif
    
    public static func log(_ message: String, level: OSLogType) {
    #if canImport(Logging)
            logger.log(level: level.toLoggerLevel(), "\(message)")
        #else
            logger.log(level: level, "\(message)")
        #endif
    }
}

#if canImport(Logging)
extension OSLogType {
    func toLoggerLevel() -> Logging.Logger.Level {
        switch self {
        case OSLogType.debug:
            return Logging.Logger.Level.debug
        case OSLogType.info:
            return Logging.Logger.Level.info
        case OSLogType.`default`:
            return Logging.Logger.Level.notice
        case OSLogType.error:
            return Logging.Logger.Level.error
        case OSLogType.fault:
            return Logging.Logger.Level.critical
        default:
            return Logging.Logger.Level.notice
        }
    }
}
#endif

