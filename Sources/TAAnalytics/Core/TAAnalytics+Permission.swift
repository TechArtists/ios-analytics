//  TAAnalytics+Permissions.swift
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

/// Protocol that uses `TAAnalyticsUIProtocol` in order to log when a permission has been shown & its response
public protocol TAAnalyticsPermissionProtocol: TAAnalyticsUIProtocol {
    /// Logs a `ui_view_show` event with `view_name="permission"` and `view_type=permissionType`
    /// - Parameter permissionType: however you want to identify the permission (e.g. "notifications", "photos")
    func trackPermissionScreenShow(for permissionType: TAPermissionType)
    
    /// Logs a `ui_button_tap` event with `name="allow"/"dont allow"`, `view_name="permission"`, `view_type=permissionType`
    func trackPermissionButtonTap(allowed: Bool, permissionType: TAPermissionType)
    
    /// Logs a `ui_button_tap` event with `name=status`, `view_name="permission"`, `view_type=permissionType`
    func trackPermissionButtonTap(status: String, permissionType: TAPermissionType)
}

// MARK: - Default Implementations

public enum TAPermissionType: CustomStringConvertible {
    case pushNotifications
    case att
    case microphone
    case location
    case custom(String)
    
    public var description: String {
        switch self {
        case .pushNotifications: return "push notifications"
        case .att: return "att"
        case .location: return "location"
        case .microphone: return "microphone"
        case .custom(let string):
            return string
        }
    }
}

extension TAAnalyticsPermissionProtocol {
    
    public func trackPermissionScreenShow(for permissionType: TAPermissionType) {
        let view = ViewAnalyticsModel(name: "permission", type: permissionType.description)
        track(viewShow: view)
    }

    public func trackPermissionButtonTap(allowed: Bool, permissionType: TAPermissionType) {
        let view = ViewAnalyticsModel(name: "permission", type: permissionType.description)
        track(buttonTap: allowed ? "allow" : "dont allow", onView: view)
    }

    public func trackPermissionButtonTap(status: String, permissionType: TAPermissionType) {
        let view = ViewAnalyticsModel(name: "permission", type: permissionType.description)
        track(buttonTap: status, onView: view)
    }

}

// MARK: - Empty Conformance

extension TAAnalytics : TAAnalyticsPermissionProtocol {}
