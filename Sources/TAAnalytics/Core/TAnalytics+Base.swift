//  TAAnalytics+Base.swift
//  Created by Adi on 10/25/22
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

// MARK: TAAnalyticsBaseProtocol

/// Base protocol for logging events & setting user properties
public protocol TAAnalyticsBaseProtocol: AnyObject {
    
    var currentProcessType: TAAnalyticsConfig.ProcessType { get }
    
    func start(customInstallUserPropertiesCompletion: (() -> ())?,
               shouldTrackFirstOpen: Bool,
               firstOpenParameterCallback: (() -> [String: (any AnalyticsBaseParameterValue)]?)?) async
    
    ///
    /// - Parameters:
    ///   - event:
    ///   - params: Note that if the parameter value is `nil`, the parameter will not be removed before sending
    ///   - logCondition: if the event should be logged for each ocurrence. Note that this only applies on a per `EventAnalyticsModel` level, parameters are not included
    func track(event: EventAnalyticsModel, params: [String: (any AnalyticsBaseParameterValue)?]?, logCondition: EventLogCondition)
    
    func set(userProperty: UserPropertyAnalyticsModel, to: String?)
    
    func get(userProperty: UserPropertyAnalyticsModel) -> String?
}

// MARK: TAAnalyticsBaseProtocol Conformance

extension TAAnalytics: TAAnalyticsBaseProtocol {
    
    public var currentProcessType: TAAnalyticsConfig.ProcessType {
        return self.config.currentProcessType
    }
    
    public func track(
        event: EventAnalyticsModel,
        params: [String: (any AnalyticsBaseParameterValue)?]? = nil,
        logCondition: EventLogCondition = .logAlways
    ) {
        let paramsWithoutNils = params?.compactMapValues { $0 }
        let prefixedEvent = prefixEventIfNeeded(event)

        func trackInAdaptors() {
            guard config.trackEventFilter(event, params) else { return }
            
            Task { [weak self] in
                guard let self else { return }
                await self.eventQueueBuffer.addEvent(prefixedEvent, params: paramsWithoutNils)
            }
        }
        switch logCondition {
        case .logAlways:
            trackInAdaptors()
        case .logOnlyOncePerLifetime:
            if self.boolFromUserDefaults(forKey: "onlyOnce_\(prefixedEvent.rawValue)") == false {
                trackInAdaptors()
                self.setInUserDefaults(true, forKey: "onlyOnce_\(prefixedEvent.rawValue)")
            }
        case .logOnlyOncePerAppSession:
            if !self.appSessionEvents.contains(event) {
                trackInAdaptors()
                appSessionEvents.insert(event)
            }
        }
    }
    
    public func set(userProperty: UserPropertyAnalyticsModel, to: String?) {
        let prefixedUserProperty = prefixUserPropertyIfNeeded(userProperty)
        self.setInUserDefaults(to, forKey: "userProperty_\(prefixedUserProperty.rawValue)")
        self.eventQueueBuffer.startedAdaptors.forEach { adaptor in
            adaptor.set(trimmedUserProperty: adaptor.trim(userProperty: prefixedUserProperty), to: to)
        }
    }

    public func get(userProperty: UserPropertyAnalyticsModel) -> String? {
        let prefixedUserProperty = prefixUserPropertyIfNeeded(userProperty)
        return self.stringFromUserDefaults(forKey: "userProperty_\(prefixedUserProperty.rawValue)")
    }

    private func prefixEventIfNeeded(_ event: EventAnalyticsModel) -> EventAnalyticsModel {
        if event.isInternalEvent {
            return event.eventBy(prefixing: config.automaticallyTrackedEventsPrefixConfig.eventPrefix)
        }
        else {
            return event.eventBy(prefixing: config.manuallyTrackedEventsPrefixConfig.eventPrefix)
        }
    }
    
    private func prefixUserPropertyIfNeeded(_ userProperty: UserPropertyAnalyticsModel) -> UserPropertyAnalyticsModel {
        if userProperty.isInternalUserProperty {
            return userProperty.userPropertyBy(prefixing: config.automaticallyTrackedEventsPrefixConfig.userPropertyPrefix)
        }
        else {
            return userProperty.userPropertyBy(prefixing: config.manuallyTrackedEventsPrefixConfig.userPropertyPrefix)
        }
    }
}
