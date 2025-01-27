//
//  EventEmitterConsumer.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.09.2024.
//

import Foundation

public class EventEmitterConsumer: AnalyticsConsumer {

    public typealias T = EventEmitterConsumer
    
    public var eventStream: AsyncStream<EventAnalyticsModelTrimmed>?
    
    private var continuationEvent: AsyncStream<EventAnalyticsModelTrimmed>.Continuation?
    
    public var propertyStream: AsyncStream<UserPropertyAnalyticsModelTrimmed>?
    
    private var continuationProperty: AsyncStream<UserPropertyAnalyticsModelTrimmed>.Continuation?
    
    public init() {}
    
    public func startFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, TAAnalytics: TAAnalytics) async throws {
        (eventStream, continuationEvent) = AsyncStream.makeStream()
        (propertyStream, continuationProperty) = AsyncStream.makeStream()
    }
    
    public func track(trimmedEvent: EventAnalyticsModelTrimmed, params: [String : any AnalyticsBaseParameterValue]?) {
        
        continuationEvent?.yield(trimmedEvent)
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
}
