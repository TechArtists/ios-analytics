//
//  EventEmitterAdaptor.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.09.2024.
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

public struct EventEmitterAnalyticsEvent: Sendable, Hashable {
    public let name: String
    public let parametersDescription: String?

    public init(name: String, parametersDescription: String? = nil) {
        self.name = name
        self.parametersDescription = parametersDescription
    }
}

/// Adaptor that provides streams for any events & user properties consumed.
///
/// Useful if you want to do some specific actions when a certain event is sent or user property set.
public class EventEmitterAdaptor: AnalyticsAdaptor {

    public typealias T = EventEmitterAdaptor
    
    public var eventStream: AsyncStream<EventEmitterAnalyticsEvent>?

    private var continuationEvent: AsyncStream<EventEmitterAnalyticsEvent>.Continuation?
    
    public var propertyStream: AsyncStream<UserPropertyAnalyticsModelTrimmed>?
    
    private var continuationProperty: AsyncStream<UserPropertyAnalyticsModelTrimmed>.Continuation?
    
    public init() {}
    
    public func startFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, taAnalytics: TAAnalytics) async throws {
        (eventStream, continuationEvent) = AsyncStream.makeStream()
        (propertyStream, continuationProperty) = AsyncStream.makeStream()
    }
    
    public func track(trimmedEvent: EventAnalyticsModelTrimmed, params: [String : any AnalyticsBaseParameterValue]?) {
        continuationEvent?.yield(
            EventEmitterAnalyticsEvent(
                name: trimmedEvent.rawValue,
                parametersDescription: Self.parametersDescription(for: params)
            )
        )
    }
    
    public func set(trimmedUserProperty: UserPropertyAnalyticsModelTrimmed, to: String?) {
        continuationProperty?.yield(trimmedUserProperty)
    }
    
    public func trim(event: EventAnalyticsModel) -> EventAnalyticsModelTrimmed {
        EventAnalyticsModelTrimmed(event.rawValue)
    }
    
    public func trim(userProperty: UserPropertyAnalyticsModel) -> UserPropertyAnalyticsModelTrimmed {
        UserPropertyAnalyticsModelTrimmed(userProperty.rawValue)
    }
    
    public var wrappedValue: Self {
        self
    }

    private static func parametersDescription(for params: [String: any AnalyticsBaseParameterValue]?) -> String? {
        guard let params, !params.isEmpty else {
            return nil
        }

        return params
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value.description)" }
            .joined(separator: ", ")
    }
}
