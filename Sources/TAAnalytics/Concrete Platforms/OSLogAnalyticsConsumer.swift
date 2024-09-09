//  OSLogAnalyticConsumer.swift
//
//  Created by Adi on 10/24/22.
//
//  Copyright (c) 2022 Tecj Artists Agenyc SRL (http://TA.com/)
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
public class OSLogAnalyticsConsumer: AnalyticsConsumer {
    
    private let logger : OSLog
    
    init() {
        self.logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "TAAnalytics")
    }
    
    public func maybeStartFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, TAAnalytics: TAAnalytics) -> Bool {
        return true
    }
    
    public func convert(parameter: AnalyticsBaseParameterValue) -> AnalyticsBaseParameterValue {
        return parameter
    }
    
    public func log(event: AnalyticsEvent, params: [String : AnalyticsBaseParameterValue]?) {
        let paramsString = params?.sorted(by: { $0.key < $1.key }).map( { "\($0.key):\($0.value.description)" }).joined(separator: ", ")
        os_log("sendEvent: '%{public}@', params: [%@]", log: logger, type: .info, event.rawValue, String(describingOptional: paramsString))
    }
        
    /// Returns a debug string for a send(event:params:) function call. Note that all the information inside this debug string is not redacted for privacy,
    /// unlike the original implementation of ConsoleAnalyticsPlatform#log(event:params:)
    ///
    /// - Parameters:
    ///   - privacyRedacted: if the parameter values should be redacted or not. If they contain PIIA, they should be redacted
    public func debugStringForLog(event: AnalyticsEvent, params: [String : AnalyticsBaseParameterValue]?, privacyRedacted: Bool) -> String {
        let paramsString : String?
        if privacyRedacted {
            paramsString = params?.sorted(by: { $0.key < $1.key }).map( { "\($0.key):<private>" }).joined(separator: ", ")
        } else {
            paramsString = params?.sorted(by: { $0.key < $1.key }).map( { "\($0.key):\($0.value.description)" }).joined(separator: ", ")
        }
        return "sendEvent: '\(event.rawValue)', params: [\(String(describingOptional: paramsString))]"
    }

    public func set(userProperty: AnalyticsUserProperty, to: String?) {
        os_log("setUserProperty: '%{public}@', value: '%@'", log: logger, type: .info, userProperty.rawValue, String(describingOptional: to))
    }
    
    /// Returns a debug string for a set(userProperty:to:) function call.
    /// Note that all the information inside this debug string is not redacted for privacy, unlike the original implementation of ConsoleAnalyticsPlatform#set(userProperty:to:))
    /// - Parameters:
    ///   - privacyRedacted: if the parameter values should be redacted or not. If they contain PIIA, they should be redacted
    public func debugStringForSet(userProperty: AnalyticsUserProperty, to: String?, privacyRedacted: Bool) -> String {
        if privacyRedacted {
            return "setUserProperty: '\(userProperty.rawValue)', value: <private>"
        } else {
            return "setUserProperty: '\(userProperty.rawValue)', value: '\(String(describingOptional:to))'"
        }
    }

}
