//  TAAnalytics+Base.swift
//  Created by Adi on 10/25/22
//
//  Copyright (c) 2022 Tech Artists Agency SRL (http://TA.com/)
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
    
    func start(customInstallUserPropertiesCompletion: (() -> ())?,
                      shouldLogFirstOpen: Bool,
                      firstOpenParameterCallback: (() -> [String: AnalyticsBaseParameterValue]?)?) async
    
    ///
    /// - Parameters:
    ///   - event:
    ///   - params:
    ///   - logCondition: if the event should be logged for each ocurrence. Note that this only applies on a per `AnalyticsEvent` level, parameters are not included
    func track(event: AnalyticsEvent, params: [String: AnalyticsBaseParameterValue]?, logCondition: EventLogCondition)
    
    func set(userProperty: AnalyticsUserProperty, to: String?)
    
    func get(userProperty: AnalyticsUserProperty) -> String?
}

// MARK: -

extension TAAnalytics: TAAnalyticsBaseProtocol {
    
    public var currentProcessType: TAAnalyticsConfig.ProcessType {
        return self.config.currentProcessType
    }
    
    public func track(
        event: AnalyticsEvent,
        params: [String: AnalyticsBaseParameterValue]? = nil,
        logCondition: EventLogCondition = .logAlways
    ) {
        let logInConsumers = {[weak self] in
            guard let self else { return }
            
            for consumer in self.config.consumers {
                if startedConsumers.isEmpty {
                    self.deferedEventQueue.enqueue(
                        .init(
                            event: event,
                            dateAdded: Date(),
                            parameters: params
                        )
                    )
                } else {
                    if self.startedConsumers.contains(where: { type(of: $0) == type(of: consumer) }) {
                            consumer.track(trimmedEvent: consumer.trim(event: event), params: params)
                            os_log("Consumer: '%{public}@' has has logged event: '%{public}@'", log: LOGGER, type: .info, String(describing: consumer), event.rawValue)
                    }
                }
            }
        }

        switch logCondition {
        case .logAlways:
            logInConsumers()
        case .logOnlyOncePerLifetime:
            if self.boolFromUserDefaults(forKey: "onlyOnce_\(event.rawValue)") == false {
                logInConsumers()
                self.setInUserDefaults(true, forKey: "onlyOnce_\(event.rawValue)")
            }
        case .logOnlyOncePerAppSession:
            if !self.appSessionEvents.contains(event) {
                logInConsumers()
                appSessionEvents.insert(event)
            }
        }
    }
    
    
    public func set(userProperty: AnalyticsUserProperty, to: String?) {
        self.setInUserDefaults(to, forKey: "userProperty_\(userProperty.rawValue)")
        self.startedConsumers.forEach { consumer in
            consumer.set(trimmedUserProperty: consumer.trim(userProperty: userProperty), to: to)
        }
    }

    public func get(userProperty: AnalyticsUserProperty) -> String? {
        return self.stringFromUserDefaults(forKey: "userProperty_\(userProperty.rawValue)")
    }

}
