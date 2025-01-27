//
//  TAAnalytics+Debug.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 16.01.2025.
//

import Foundation

// MARK: - TAAnalyticsDebugProtocol

/// Protocol for sending specialized `debug_foo` events.
/// These events are used to temporarily debug issues in production.
/// The `debug_` prefix helps the data analytics team identify these events.
public protocol TAAnalyticsDebugProtocol: TAAnalyticsBaseProtocol {
    /// Logs a `debug_foo` event with optional details.
    ///
    /// - Parameters:
    ///   - eventSuffix: The suffix appended to the event name (e.g., `foo` results in `debug_foo`).
    ///   - extraParams: Additional parameters to include with the event.
    func trackDebugEvent(eventSuffix: String, extraParams: [String: (any AnalyticsBaseParameterValue)]?)
}

// MARK: - Default Implementations

public extension TAAnalyticsDebugProtocol {
    func trackDebugEvent(eventSuffix: String, extraParams: [String: (any AnalyticsBaseParameterValue)]? = nil) {
        let eventName = "debug_\(eventSuffix)"
        track(event: EventAnalyticsModel(eventName), params: extraParams, logCondition: .logAlways)
    }
}

// MARK: - Conformance

extension TAAnalytics: TAAnalyticsDebugProtocol {}
