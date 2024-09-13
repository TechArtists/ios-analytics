//
//  EventEmitterConsumer.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.09.2024.
//

import Foundation

//public protocol EventEmitterProtocol {
//    var eventStream: AsyncStream<TrimmedEvent>? { get }
//    var propertyStream: AsyncStream<TrimmedUserProperty>? { get }
//}

public class EventEmitterConsumer: AnalyticsConsumer {
    
    public typealias T = EventEmitterConsumer
    
    public var eventStream: AsyncStream<TrimmedEvent>?
    
    private var continuationEvent: AsyncStream<TrimmedEvent>.Continuation?
    
    public var propertyStream: AsyncStream<TrimmedUserProperty>?
    
    private var continuationProperty: AsyncStream<TrimmedUserProperty>.Continuation?
    
    public init() {}
    
    public func maybeStartFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, TAAnalytics: TAAnalytics) -> Bool {
        (eventStream, continuationEvent) = AsyncStream.makeStream()
        (propertyStream, continuationProperty) = AsyncStream.makeStream()
        
        return true
    }
    
    public func log(trimmedEvent: TrimmedEvent, params: [String : any AnalyticsBaseParameterValue]?) {
        
        continuationEvent?.yield(trimmedEvent)
    }
    
    public func set(trimmedUserProperty: TrimmedUserProperty, to: String?) {
        continuationProperty?.yield(trimmedUserProperty)
    }
    
    public func trim(event: AnalyticsEvent) -> TrimmedEvent {
        TrimmedEvent(event.rawValue)
    }
    
    public func trim(userProperty: AnalyticsUserProperty) -> TrimmedUserProperty {
        TrimmedUserProperty(userProperty.rawValue)
    }
    
    public var wrappedValue: Self {
        self
    }
}
