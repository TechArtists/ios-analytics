//
//  TAAnalytics+ATT.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 26.03.2025.
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
import AppTrackingTransparency
import AdSupport

// MARK: - TAAnalyticsDebugProtocol

/// Protocol for handling App Tracking Transparency (ATT) permission flow and related analytics events.
///
/// This protocol provides methods for requesting ATT permission and tracking whether the prompt
/// was shown, granted, denied, or not allowed.
public protocol TAAnalyticsATTProtocol: TAAnalyticsBaseProtocol {
    
    /// Requests App Tracking Transparency (ATT) permission from the user.
    ///
    /// - Returns: The resulting `ATTrackingManager.AuthorizationStatus`.
    func requestAttPermission() async -> ATTrackingManager.AuthorizationStatus
    
    /// Tracks an event when the ATT prompt is not allowed to be shown.
    ///
    /// - Parameter extraParams: Optional additional event parameters.
    func trackATTPromptNotAllowed(extraParams: [String: (any AnalyticsBaseParameterValue)]?)
    
    /// Tracks an event when the ATT prompt is displayed to the user.
    ///
    /// - Parameter extraParams: Optional additional event parameters.
    func trackATTPromptShow(extraParams: [String: (any AnalyticsBaseParameterValue)]?)
    
    /// Tracks an event when ATT permission is granted by the user.
    ///
    /// - Parameter extraParams: Optional additional event parameters.
    func trackATTPromptGranted(extraParams: [String: (any AnalyticsBaseParameterValue)]?)
    
    /// Tracks an event when ATT permission is denied by the user.
    ///
    /// - Parameter extraParams: Optional additional event parameters.
    func trackATTPromptDenied(extraParams: [String: (any AnalyticsBaseParameterValue)]?)
}

// MARK: - Default Implementations

extension TAAnalytics: TAAnalyticsATTProtocol {
    
    /// Handles the ATT permission request lifecycle and tracks the appropriate event.
    ///
    /// - If permission is not allowed (e.g., due to MDM or parental controls), logs `.ATT_PROMPT_NOT_ALLOWED`.
    /// - If permission is requestable (`.notDetermined`), calls `requestTrackingAuthorization()` and logs:
    ///     - `.ATT_PROMPT_SHOW` immediately,
    ///     - `.ATT_PROMPT_GRANTED` or `.ATT_PROMPT_DENIED` based on user choice.
    /// - Marks ATT permission as requested using `UserDefaults` key `permissionATTRequested`
    ///
    /// - Returns: The resulting `ATTrackingManager.AuthorizationStatus`.
    public func requestAttPermission() async -> ATTrackingManager.AuthorizationStatus {
        let status = ATTrackingManager.trackingAuthorizationStatus
        let permissionRequested = self.boolFromUserDefaults(forKey: UserDefaultKeys.permissionATTRequested) ?? false

        if !permissionRequested, status == .denied || status == .restricted {
            trackATTPromptNotAllowed(extraParams: status.eventParameters)
            self.setInUserDefaults(true, forKey: UserDefaultKeys.permissionATTRequested)
        }

        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            let status = await ATTrackingManager.requestTrackingAuthorization()
            trackATTPromptShow(extraParams: status.eventParameters)
            self.setInUserDefaults(true, forKey: UserDefaultKeys.permissionATTRequested)
            switch status {
            case .authorized:
                let params = ["advertisingIdentifier": "\(ASIdentifierManager.shared().advertisingIdentifier)"]
                trackATTPromptGranted(
                    extraParams: status.eventParameters.merging(params) { (_, new) in new }
                )
            case .denied, .restricted:
                trackATTPromptDenied(extraParams: status.eventParameters)
            default:
                break
            }
            return status
        }

        return status
    }
    
    /// Logs `.ATT_PROMPT_NOT_ALLOWED` when ATT cannot be requested.
    ///
    /// This happens on first launch if ATT is disabled in settings or the device is under MDM/parental restrictions.
    ///
    /// - Parameter extraParams: Additional event parameters (optional).
    public func trackATTPromptNotAllowed(extraParams: [String : (any AnalyticsBaseParameterValue)]? = nil) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        extraParams?.forEach({ key, value in params[key] = value })

        track(event: .ATT_PROMPT_NOT_ALLOWED, params: params, logCondition: .logAlways)
    }
    
    /// Logs `.ATT_PROMPT_SHOW` when the ATT prompt is shown via `requestTrackingAuthorization()`.
    ///
    /// Tracked only when ATT status is `.notDetermined`, indicating a first-time request.
    ///
    /// - Parameter extraParams: Additional event parameters (optional).
    public func trackATTPromptShow(extraParams: [String : (any AnalyticsBaseParameterValue)]? = nil) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        extraParams?.forEach({ key, value in params[key] = value })

        track(event: .ATT_PROMPT_SHOW, params: params, logCondition: .logAlways)
        
        let view = ViewAnalyticsModel(name: "permission", type: TAPermissionType.att.description)
        track(viewShow: view)
    }
    
    /// Logs `.ATT_PROMPT_GRANTED` after the user explicitly allows tracking.
    ///
    /// This follows an ATT prompt and is only sent after `.ATT_PROMPT_SHOW`.
    ///
    /// - Parameter extraParams: Additional event parameters (optional).
    public func trackATTPromptGranted(extraParams: [String : (any AnalyticsBaseParameterValue)]? = nil) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        extraParams?.forEach({ key, value in params[key] = value })

        track(event: .ATT_PROMPT_GRANTED, params: params, logCondition: .logAlways)
        
        let view = ViewAnalyticsModel(name: "permission", type: TAPermissionType.att.description)
        track(viewShow: view)
    }
    
    /// Logs `.ATT_PROMPT_DENIED` after the user explicitly denies tracking.
    ///
    /// This follows an ATT prompt and is only sent after `.ATT_PROMPT_SHOW`.
    ///
    /// - Parameter extraParams: Additional event parameters (optional).
    public func trackATTPromptDenied(extraParams: [String : (any AnalyticsBaseParameterValue)]? = nil) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        extraParams?.forEach({ key, value in params[key] = value })

        track(event: .ATT_PROMPT_DENIED, params: params, logCondition: .logAlways)
        
        let view = ViewAnalyticsModel(name: "permission", type: TAPermissionType.att.description)
        track(viewShow: view)
    }
}

extension ATTrackingManager.AuthorizationStatus {

    /// Returns a dictionary with string and numeric representations of the ATT status.
    ///
    /// Used for attaching ATT state context to analytics events.
    var eventParameters: [String : (any AnalyticsBaseParameterValue)] {
        [
            "att_status": stringValue,
            "att_status_code": Int(rawValue)
        ]
    }

    /// Returns a string representation of the current ATT status.
    ///
    /// Used for labeling ATT events with human-readable status.
    var stringValue: String {
        switch self {
        case .notDetermined:
            return "not_determined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        default:
            return "unknown"
        }
    }
}
