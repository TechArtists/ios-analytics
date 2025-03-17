/*
MIT License

Copyright (c) 2025 Tech Artists Agency

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
