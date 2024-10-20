//  DefaultConstants.swift
//  Created by Adi on 10/24/22
//
//  Copyright (c) 2022 Tech Artists Agency SRL (http://TA.com/)
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

public extension AnalyticsEvent {
    static let FIRST_OPEN = AnalyticsEvent("first_open", isTAInternalEvent: true)
    
    static let UI_VIEW_SHOWN = AnalyticsEvent("ui_view_shown")
    static let UI_BUTTON_TAPPED = AnalyticsEvent("ui_button_tapped")
    
    /// Sent when the app goes to the foreground as detected by `UIApplication.willEnterForegroundNotification`
    static let APP_FOREGROUND = AnalyticsEvent("app_foreground", isTAInternalEvent: true)
    /// Sent when the app goes to the background as detected by `UIApplication.didEnterBackgroundNotification`. It also has parameters for the `last_parent_view` that was shown (aka no subviews).
    static let APP_BACKGROUND = AnalyticsEvent("app_background", isTAInternalEvent: true)
    
    /// Parameters `from_version`, `to_version` (retrieved via `CFBundleShortVersionString` & `from_build`, `to_build` (retrieved via `CFBundleVersion`)
    static let APP_VERSION_UPDATE = AnalyticsEvent("app_version_update", isTAInternalEvent: true)
    /// Parameters `from_version`, `to_version` (retrieved via `ProcessInfo.processInfo.operatingSystemVersion`)
    static let OS_VERSION_UPDATE = AnalyticsEvent("os_version_update", isTAInternalEvent: true)
}

public extension AnalyticsUserProperty {
    static let ANALYTICS_VERSION = AnalyticsUserProperty("analytics_version", isInternalUserProperty: true)
    
    static let APP_VERSION = AnalyticsUserProperty("app_version", isInternalUserProperty: true)
    static let DEVICE_LANGUAGE = AnalyticsUserProperty("device_language", isInternalUserProperty: true)
    static let INSTALL_DEVICE_LANGUAGE = AnalyticsInstallUserProperty("device_language", isTAInternalUserProperty: true)
    static let INSTALL_DEVICE_LANGUAGE2 = AnalyticsInstallUserProperty("install_device_language", isTAInternalUserProperty: true)
    
    /// The date of the install, in ISO 8601 format (YYYY-MM-DD)
    static let INSTALL_DATE    = AnalyticsUserProperty("install_date", isInternalUserProperty: true)
    /// The version of the app at install time
    static let INSTALL_VERSION = AnalyticsUserProperty("install_version", isInternalUserProperty: true)
    /// The version of the platform/operating system
    static let INSTALL_PLATFORM_VERSION = AnalyticsUserProperty("install_platform_version", isInternalUserProperty: true)
    /// If this is jailbroken at install time
    static let INSTALL_IS_JAILBROKEN = AnalyticsUserProperty("install_is_jailbroken", isInternalUserProperty: true)
    /// The ui appearance at install time
    static let INSTALL_UI_APPEARANCE = AnalyticsUserProperty("install_ui_appearance", isInternalUserProperty: true)
    /// The dynamic type at install time
    static let INSTALL_DYNAMIC_TYPE  = AnalyticsUserProperty("install_dynamic_type", isInternalUserProperty: true)

    /// Ever increasing counter on each cold app launch, starting from 1 at first open.
    static let COLD_APP_LAUNCH_COUNT = AnalyticsUserProperty("cold_app_launch_count", isInternalUserProperty: true)
    /// Ever increasing counter on each app foreground, starting from 1 at first open
    static let FOREGROUND_COUNT = AnalyticsUserProperty("foreground_count", isInternalUserProperty: true)
    
    /// This is only shown for parent views (aka those with "parent view" set to nil). It's has multiple fields concatenated by `;` `view_name;view_type;group_name;group_order;group_stage`
    static let LAST_PARENT_VIEW_SHOWN = AnalyticsUserProperty("last_parent_view_shown", isInternalUserProperty: true)
    
    // TODO: adi add Experiments
    
    /// If the variant is control/test.
    // TODO: move this out
//    static let INSTALL_VARIANT = AnalyticsUserProperty("install_variant")
    // TODO: Move this out
    /// The attribution network at install time
//    static let INSTALL_ATTR_NETWORK     = AnalyticsUserProperty("install_attr_network")
    /// The attribution campaign at install time
//    static let INSTALL_ATTR_CAMPAIGN    = AnalyticsUserProperty("install_attr_campaign")
}

