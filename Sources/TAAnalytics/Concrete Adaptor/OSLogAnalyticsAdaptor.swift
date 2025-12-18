//  OSLogAnalyticAdaptor.swift
//
//  Created by Adi on 10/24/22.
//
//  Copyright (c) 2022 Tech Artists Agency SRL
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import OSLog

/// Logs to OSLog. `OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "TAAnalytics")`
public class OSLogAnalyticsAdaptor: AnalyticsAdaptor {
    
    public typealias T = OSLogAnalyticsAdaptor
    
    private let logger : OSLog
    
    public init() {
        self.logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "TAAnalytics")
    }
    
    public func startFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, taAnalytics: TAAnalytics) async throws {
        
    }
    
    public func convert(parameter: (any AnalyticsBaseParameterValue)) -> (any AnalyticsBaseParameterValue) {
        return parameter
    }
    
    public func track(trimmedEvent: EventAnalyticsModelTrimmed, params: [String : (any AnalyticsBaseParameterValue)]?) {
        let paramsString = params?.sorted(by: { $0.key < $1.key }).map( { "\($0.key):\($0.value.description)" }).joined(separator: ", ")
        TALogger.log(level: .info, "sendEvent: \(trimmedEvent.rawValue), params: \(String(describingOptional: paramsString))")
    }
    
    public func trim(event: EventAnalyticsModel) -> EventAnalyticsModelTrimmed {
        EventAnalyticsModelTrimmed(event.rawValue.ta_trim(toLength: 40, debugType: "event"))
    }
    
    public func trim(userProperty: UserPropertyAnalyticsModel) -> UserPropertyAnalyticsModelTrimmed {
        UserPropertyAnalyticsModelTrimmed(userProperty.rawValue.ta_trim(toLength: 24, debugType: "user property"))
    }
    
    public var wrappedValue: Self {
        self
    }
        
    /// Returns a debug string for a send(event:params:) function call. Note that all the information inside this debug string is not redacted for privacy,
    /// unlike the original implementation of ConsoleAnalyticsPlatform#log(event:params:)
    ///
    /// - Parameters:
    ///   - privacyRedacted: if the parameter values should be redacted or not. If they contain PIIA, they should be redacted
    public func debugStringForLog(eventRawValue: String, params: [String : (any AnalyticsBaseParameterValue)]?, privacyRedacted: Bool) -> String {
        let paramsString : String?
        if privacyRedacted {
            paramsString = params?.sorted(by: { $0.key < $1.key }).map( { "\($0.key):<private>" }).joined(separator: ", ")
        } else {
            paramsString = params?.sorted(by: { $0.key < $1.key }).map( { "\($0.key):\($0.value.description)" }).joined(separator: ", ")
        }
        return "sendEvent: '\(eventRawValue)', params: [\(String(describingOptional: paramsString))]"
    }

    public func set(trimmedUserProperty: UserPropertyAnalyticsModelTrimmed, to: String?) {        
        TALogger.log(level: .info, "setUserProperty: '\(trimmedUserProperty.rawValue)', value: '\(String(describingOptional: to))'")
    }
    
    /// Returns a debug string for a set(userProperty:to:) function call.
    /// Note that all the information inside this debug string is not redacted for privacy, unlike the original implementation of ConsoleAnalyticsPlatform#set(userProperty:to:))
    /// - Parameters:
    ///   - privacyRedacted: if the parameter values should be redacted or not. If they contain PIIA, they should be redacted
    public func debugStringForSet(userPropertyRawValue: String, to: String?, privacyRedacted: Bool) -> String {
        if privacyRedacted {
            return "setUserProperty: '\(userPropertyRawValue)', value: <private>"
        } else {
            return "setUserProperty: '\(userPropertyRawValue)', value: '\(String(describingOptional:to))'"
        }
    }
}
