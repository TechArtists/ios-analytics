//  TAAnalytics+Error.swift
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

// MARK: -

/// Protocol that sends a specialized `error foo` event. If there is an acoompanying `Error`, it will also send
/// alongside the `domain`, `code` & `localizedDescription`
public protocol TAAnalyticsErrorProtocol: TAAnalyticsBaseProtocol {

    /// Logs an `error` event with some details about the error
    ///
    /// If an `error` is passed, these extra parameters will be added:
    ///
    ///      error_domain: String?
    ///      error_code: Int?
    ///      error_description: String?
    ///
    /// - Parameters:
    ///   - reason: a developer reason about what triggered the error state (e.g. `couldnt find any valid JWT token`)
    ///   - error: if there is a specific `Error` that triggered this. If so, `domain`, `code` & `description` parameters are added
    ///   - extraParams: any extra params to send (e.g. `error cant login user`, `reason`:`server down`
    func trackErrorEvent(reason: String, error: Error?, extraParams: [String: (any AnalyticsBaseParameterValue)]?)
    
    /// Logs an `error_corrected` event with some details about the error. Use this if you want to specify that the previous error tracked state has been solved.
    /// Useful to be able to measure false positives from the analytics.
    ///
    /// If an `error_corrected` is passed, these extra parameters will be added:
    ///
    ///      error_domain: String?
    ///      error_code: Int?
    ///      error_description: String?
    ///
    /// - Parameters:
    ///   - reason: a developer reason about what triggered the error state that has since corrected (e.g. `couldnt find any valid JWT token`)
    ///   - error: if there is a specific `Error` that triggered this. If so, `domain`, `code` & `description` parameters are added
    ///   - extraParams: any extra params to send (e.g. `error cant login user`, `reason`:`server down`
    func trackErrorCorrectedEvent(reason: String, error: Error?, extraParams: [String: (any AnalyticsBaseParameterValue)]?)
}

// MARK: - Default Implementations

public extension TAAnalyticsErrorProtocol {
    /// Logs an `error_foo` event with some details about the error
    ///
    /// The EventAnalyticsModel is sent alongside these parameters if an `error` parameter is present:
    ///
    ///      domain: String?
    ///      code: Int?
    ///      description: String?
    ///
    ///
    /// - Parameters:
    ///   - reason: the reason that will be added as the event parameter "reason"
    ///   - error: if there is a specific `Error` that triggered this. If so, `domain`, `code` & `description` parameters are added
    ///   - extraParams: any extra params to send (e.g. `error cant login user`, `reason`:`server down`
    func trackErrorEvent(reason: String, error: Error? = nil, extraParams: [String: (any AnalyticsBaseParameterValue)]? = nil) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        params["reason"] = reason
        
        if let error = error {
            let nserror = error as NSError
            params["error_domain"] = nserror.domain
            params["error_code"] = nserror.code
            params["error_description"] = nserror.localizedDescription
        }
        extraParams?.forEach({ key, value in params[key] = value })
        track(event: .ERROR, params: params, logCondition: .logAlways)
    }
    
    func trackErrorCorrectedEvent(reason: String, error: Error? = nil, extraParams: [String: (any AnalyticsBaseParameterValue)]? = nil) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        params["reason"] = reason
        
        if let error = error {
            let nserror = error as NSError
            params["error_domain"] = nserror.domain
            params["error_code"] = nserror.code
            params["error_description"] = nserror.localizedDescription
        }
        extraParams?.forEach({ key, value in params[key] = value })
        track(event: .ERROR_CORRECTED, params: params, logCondition: .logAlways)
    }

    
    
}

// MARK: - Empty Conformance

extension TAAnalytics: TAAnalyticsErrorProtocol {}
