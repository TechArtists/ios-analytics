//  TAAnalytics+Error.swift
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

// MARK: -

/// Protocol that sends a specialized `error foo` event. If there is an acoompanying `Error`, it will also send
/// alongside the `domain`, `code` & `localizedDescription`
public protocol TAAnalyticsErrorProtocol: TAAnalyticsBaseProtocol {

    /// Logs an `error foo` event with some details about the error
    ///
    /// The AnalyticsEvent is sent alongside these parameters if an `error` parameter is present:
    ///
    ///      domain: String?
    ///      code: Int?
    ///      description: String?
    ///
    /// - Parameters:
    ///   - eventSuffix: the suffix that will be appended to the event name (e.g. `error_foo`)
    ///   - error: if there is a specific `Error` that triggered this. If so, `domain`, `code` & `description` parameters are added
    ///   - extraParams: any extra params to send (e.g. `error cant login user`, `reason`:`server down`
    func logErrorEvent(eventSuffix: String, error: Error?, extraParams: [String: AnalyticsBaseParameterValue]?)
}

// MARK: - Default Implementations

public extension TAAnalyticsErrorProtocol {
    /// Logs an `error_foo` event with some details about the error
    ///
    /// The AnalyticsEvent is sent alongside these parameters if an `error` parameter is present:
    ///
    ///      domain: String?
    ///      code: Int?
    ///      description: String?
    ///
    ///
    /// - Parameters:
    ///   - eventSuffix: the suffix that will be appended to the event name (e.g. `error foo`)
    ///   - error: if there is a specific `Error` that triggered this. If so, `domain`, `code` & `description` parameters are added
    ///   - extraParams: any extra params to send (e.g. `error cant login user`, `reason`:`server down`
    func logErrorEvent(eventSuffix: String, error: Error? = nil, extraParams: [String: AnalyticsBaseParameterValue]? = nil) {
        var params = [String: AnalyticsBaseParameterValue]()
        if let error = error {
            let nserror = error as NSError
            params["domain"] = nserror.domain
            params["code"] = nserror.code
            params["description"] = nserror.localizedDescription
        }
        extraParams?.forEach({ key, value in params[key] = value })
        log(event: AnalyticsEvent("error_\(eventSuffix)"), params: params, logCondition: .logAlways)
    }
}

// MARK: - Empty Conformance

extension TAAnalytics: TAAnalyticsErrorProtocol {}
