//
//  EventEmitterConsumer.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.09.2024.
//

import Foundation

public class EventEmitterConsumer: AnalyticsConsumer {

    public typealias T = EventEmitterConsumer
    
    public var eventStream: AsyncStream<AnalyticsEventTrimmed>?
    
    private var continuationEvent: AsyncStream<AnalyticsEventTrimmed>.Continuation?
    
    public var propertyStream: AsyncStream<AnalyticsUserPropertyTrimmed>?
    
    private var continuationProperty: AsyncStream<AnalyticsUserPropertyTrimmed>.Continuation?
    
    public init() {}
    
    public func startFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, TAAnalytics: TAAnalytics) async throws {
        (eventStream, continuationEvent) = AsyncStream.makeStream()
        (propertyStream, continuationProperty) = AsyncStream.makeStream()
    }
    
    public func track(trimmedEvent: AnalyticsEventTrimmed, params: [String : any AnalyticsBaseParameterValue]?) {
        
        continuationEvent?.yield(trimmedEvent)
    }
    
    public func set(trimmedUserProperty: AnalyticsUserPropertyTrimmed, to: String?) {
        continuationProperty?.yield(trimmedUserProperty)
    }
    
    public func trim(event: AnalyticsEvent) -> AnalyticsEventTrimmed {
        AnalyticsEventTrimmed(event.rawValue)
    }
    
    public func trim(userProperty: AnalyticsUserProperty) -> AnalyticsUserPropertyTrimmed {
        AnalyticsUserPropertyTrimmed(userProperty.rawValue)
    }
    
    public var wrappedValue: Self {
        self
    }
}
