//
//  TAAnalytics+Debug.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 16.01.2025.
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

// MARK: - TAAnalyticsDebugProtocol

/// Protocol for sending specialized `debug_foo` events.
/// These events are used to temporarily debug issues in production.
/// The `debug_` prefix helps the data analytics team identify these events.
public protocol TAAnalyticsDebugProtocol: TAAnalyticsBaseProtocol {
    /// Logs a `debug_foo` event with optional details.
    ///
    /// - Parameters:
    ///   - reason: a developer reason about what triggered the debug state (e.g. `couldnt find any valid JWT token`)
    ///   - extraParams: Additional parameters to include with the event.
    func trackDebugEvent(reason: String, extraParams: [String: (any AnalyticsBaseParameterValue)]?)
}

// MARK: - Default Implementations

public extension TAAnalyticsDebugProtocol {
    func trackDebugEvent(reason: String, extraParams: [String: (any AnalyticsBaseParameterValue)]? = nil) {
        let eventName = "debug"
        var params = [String: (any AnalyticsBaseParameterValue)]()
        params["reason"] = reason
        extraParams?.forEach({ key, value in params[key] = value })

        track(event: EventAnalyticsModel(eventName), params: params, logCondition: .logAlways)
    }
}

// MARK: - Conformance

extension TAAnalytics: TAAnalyticsDebugProtocol {}
