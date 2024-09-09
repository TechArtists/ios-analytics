//  TAAnalytics+Base.swift
//  Created by Adi on 10/25/22
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

import Foundation
import OSLog

// MARK: -

/// Base protocol for logging events & setting user properties
public protocol TAAnalyticsBaseProtocol {
    
    var currentProcessType: TAAnalyticsConfig.ProcessType { get }
    
    func start(beforeLoggingFirstOpenCompletion: (() -> ())?,
                      shouldLogFirstOpen: Bool,
                      firstOpenParameterCallback: (() -> [String: AnalyticsBaseParameterValue]?)?)
    
    ///
    /// - Parameters:
    ///   - event:
    ///   - params:
    ///   - logCondition: if the event should be logged for each ocurrence. Note that this only applies on a per `AnalyticsEvent` level, parameters are not included
    func log(event: AnalyticsEvent, params: [String: AnalyticsBaseParameterValue]?, logCondition: EventLogCondition)
    
    func set(userProperty: AnalyticsUserProperty, to: String?)
    
    func get(userProperty: AnalyticsUserProperty) -> String?
}

// MARK: -

extension TAAnalytics: TAAnalyticsBaseProtocol {
    public var currentProcessType: TAAnalyticsConfig.ProcessType {
        return self.config.currentProcessType
    }
    
    
    public func log(event: AnalyticsEvent, params: [String: AnalyticsBaseParameterValue]? = nil, logCondition: EventLogCondition = .logAlways) {
        let logInPlaforms = { self.startedPlatforms.forEach { platform in platform.log(event: event, params: params) } }

        switch logCondition {
        case .logAlways:
            logInPlaforms()
        case .logOnlyOncePerLifetime:
            if self.boolFromUserDefaults(forKey: "onlyOnce_\(event.rawValue)") == false {
                logInPlaforms()
                self.setInUserDefaults(true, forKey: "onlyOnce_\(event.rawValue)")
            }
        case .logOnlyOncePerAppSession:
            if !self.appSessionEvents.contains(event) {
                logInPlaforms()
                appSessionEvents.insert(event)
            }
        }
    }
    
    
    public func set(userProperty: AnalyticsUserProperty, to: String?) {
        self.setInUserDefaults(to, forKey: "userProperty_\(userProperty.rawValue)")
        self.startedPlatforms.forEach { platform in platform.set(userProperty: userProperty, to: to) }
    }

    public func get(userProperty: AnalyticsUserProperty) -> String? {
        return self.stringFromUserDefaults(forKey: "userProperty_\(userProperty.rawValue)")
    }

}

