//  DefaultConstants.swift
//  Created by Adi on 10/24/22
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

public extension EventAnalyticsModel {
    static let OUR_FIRST_OPEN = EventAnalyticsModel("our_first_open", isTAInternalEvent: true)
    
    static let UI_VIEW_SHOW = EventAnalyticsModel("ui_view_show")
    static let UI_BUTTON_TAP = EventAnalyticsModel("ui_button_tap")
        
    /// Sent when the app goes to the foreground as detected by `UIApplication.willEnterForegroundNotification`. It has an `is_cold_launch` boolean parameter
    static let APP_OPEN = EventAnalyticsModel("app_open", isTAInternalEvent: true)
    /// Sent when the app goes to the background as detected by `UIApplication.didEnterBackgroundNotification`. It also has parameters for the `last_parent_view` that was shown (aka no subviews).
    static let APP_CLOSE = EventAnalyticsModel("app_close", isTAInternalEvent: true)
    
    /// Parameters `reason` (mandatory) and optionally `"error_domain", "error_code", "error_description"` if an NSError was passed
    static let ERROR = EventAnalyticsModel("error", isTAInternalEvent: true)
    /// Parameters `reason` (mandatory) and optionally `"error_domain", "error_code", "error_description"` if an NSError was passed. Use this when you want to specify that the error state has been resolved
    static let ERROR_CORRECTED = EventAnalyticsModel("error_corrected", isTAInternalEvent: true)
    
    
    /// Parameters `from_version`, `to_version` (retrieved via `CFBundleShortVersionString` & `from_build`, `to_build` (retrieved via `CFBundleVersion`)
    static let APP_VERSION_UPDATE = EventAnalyticsModel("app_version_update", isTAInternalEvent: true)
    /// Parameters `from_version`, `to_version` (retrieved via `ProcessInfo.processInfo.operatingSystemVersion`)
    static let OS_VERSION_UPDATE = EventAnalyticsModel("os_version_update", isTAInternalEvent: true)
    
    /// Parameters `name`, the name of the engagement and all the last parent view shown is automatically added as parameters with `view_%`
    static let ENGAGEMENT = EventAnalyticsModel("engagement", isTAInternalEvent: true)
    /// Send this when you consider something the primary engagement of the app. This is sent alongside the usual `ENGAGEMENT` event with the same parameters
    static let ENGAGEMENT_PRIMARY = EventAnalyticsModel("engagement_primary", isTAInternalEvent: true)
    
    /// Sent when the onboarding starts and the very first screen is shown
    static let ONBOARDING_ENTER = EventAnalyticsModel("onboarding_enter", isTAInternalEvent: true)
    /// Sent when the onboarding is finished
    static let ONBOARDING_EXIT = EventAnalyticsModel("onboarding_exit", isTAInternalEvent: true)
    //// Sent when the account signup starts
    static let ACCOUNT_SIGNUP_ENTER = EventAnalyticsModel("account_signup_enter", isTAInternalEvent: true)
    //// Sent when the account signup ends
    static let ACCOUNT_SIGNUP_EXIT = EventAnalyticsModel("account_signup_exit", isTAInternalEvent: true)
    
    /// Parameters `placement`, `id` (optional)
    /// This also sends the `ui_view_show` event in the background with `name="paywall"` and `type=<placement>`
    static let PAYWALL_ENTER = EventAnalyticsModel("paywall_show", isTAInternalEvent: true)
    /// Parameters `placement`, `id` (optional)
    static let PAYWALL_EXIT = EventAnalyticsModel("paywall_exit", isTAInternalEvent: true)
    /// Parameters `button_name`, `product_id`, `paywall_placement`, `paywall_id` (optional),
    /// This also sends the `ui_button_tapped` event in the background with `name="purchase"`, `extra=<actualButtonName>`, `view_name=paywall`, `view_type=<paywallPlacement>`
    static let PAYWALL_PURCHASE_TAP = EventAnalyticsModel("paywall_purchase_tap", isTAInternalEvent: true)

    static let SUBSCRIPTION_START_INTRO = EventAnalyticsModel("subscripton_start_intro", isTAInternalEvent: true)
    static let SUBSCRIPTION_START_PAID_REGULAR = EventAnalyticsModel("subscripton_start_paid_regular", isTAInternalEvent: true)
    static let SUBSCRIPTION_START_NEW = EventAnalyticsModel("subscripton_start_new", isTAInternalEvent: true)
    static let SUBSCRIPTION_RESTORE   = EventAnalyticsModel("subscripton_restore", isTAInternalEvent: true)

    static let ATT_PROMPT_NOT_ALLOWED = EventAnalyticsModel("att_prompt_not_allowed", isTAInternalEvent: true)
    static let ATT_PROMPT_SHOW        = EventAnalyticsModel("att_prompt_show", isTAInternalEvent: true)
    static let ATT_PROMPT_TAP_ALLOW   = EventAnalyticsModel("att_prompt_tap_allow", isTAInternalEvent: true)
    static let ATT_PROMPT_TAP_DENY    = EventAnalyticsModel("att_prompt_tap_deny", isTAInternalEvent: true)
}

public extension UserPropertyAnalyticsModel {
    /// The introductory offer from the current active subscription. If the introductory offer has passed, this will become nil.
    /// Possible values: "trial" or "pay as you go" or "pay up front"
    static let SUBSCRIPTION_INTRO_OFFER = UserPropertyAnalyticsModel("subscription_intro_offer", isInternalUserProperty: true)

    /// The product identifier of the currently active subscription
    static let SUBSCRIPTION = UserPropertyAnalyticsModel("subscription", isInternalUserProperty: true)
    /// The product identifier of the currently active subscription that is separate from the main subscription.
    /// Use this when there are multiple subscription active at the same time
    static let SUBSCRIPTION2 = UserPropertyAnalyticsModel("subscription2", isInternalUserProperty: true)
}

public extension UserPropertyAnalyticsModel {
    static let ANALYTICS_VERSION = UserPropertyAnalyticsModel("analytics_version", isInternalUserProperty: true)
    
    /// The date of the install, in ISO 8601 format (YYYY-MM-DD)
    static let INSTALL_DATE    = UserPropertyAnalyticsModel("install_date", isInternalUserProperty: true)
    /// The version of the app at install time
    static let INSTALL_VERSION = UserPropertyAnalyticsModel("install_version", isInternalUserProperty: true)
    /// The version of the platform/operating system
    static let INSTALL_OS_VERSION = UserPropertyAnalyticsModel("install_os_version", isInternalUserProperty: true)
    /// If this is jailbroken at install time
    static let INSTALL_IS_JAILBROKEN = UserPropertyAnalyticsModel("install_is_jailbroken", isInternalUserProperty: true)
    /// The ui appearance at install time
    static let INSTALL_UI_APPEARANCE = UserPropertyAnalyticsModel("install_ui_appearance", isInternalUserProperty: true)
    /// The dynamic type at install time
    static let INSTALL_DYNAMIC_TYPE  = UserPropertyAnalyticsModel("install_dynamic_type", isInternalUserProperty: true)

    /// Ever increasing counter on each cold app launch, starting from 1 at first open.
    static let APP_COLD_LAUNCH_COUNT = UserPropertyAnalyticsModel("app_cold_launch_count", isInternalUserProperty: true)
    /// Ever increasing counter on each app open, starting from 1 at first open
    static let APP_OPEN_COUNT = UserPropertyAnalyticsModel("app_open_count", isInternalUserProperty: true)
    
    /// This is only shown for parent views (aka those with "parent view" set to nil). It's has multiple fields concatenated by `;` `view_name;view_type;funnel_name;funnel_step;funnel_step_is_optional;funnel_step_is_final`
    static let LAST_VIEW_SHOW = UserPropertyAnalyticsModel("last_view_show", isInternalUserProperty: true)
        
    
    // TODO: adi sd add Experiments or ABTesting mechanism that's dependent on feature flags
    // prefix all curent running experiments with `ab_%`
    
    /// If the variant is control/test.
    // TODO: Move this out
    /// The attribution network at install time
//    static let INSTALL_ATTR_NETWORK     = AnalyticsUserProperty("install_attr_network")
    /// The attribution campaign at install time
//    static let INSTALL_ATTR_CAMPAIGN    = AnalyticsUserProperty("install_attr_campaign")
}
