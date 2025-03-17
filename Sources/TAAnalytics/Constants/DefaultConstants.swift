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

public extension EventAnalyticsModel {
    static let FIRST_OPEN = EventAnalyticsModel("first_open", isTAInternalEvent: true)
    
    
    static let ui_view_show = EventAnalyticsModel("ui_view_show")
    static let UI_BUTTON_TAP = EventAnalyticsModel("ui_button_tap")
    
    static let error_stuck_on_ui_view_show = EventAnalyticsModel("error_stuck_on_ui_view_show")
    static let corrected_error_stuck_on_ui_view_show = EventAnalyticsModel("corrected_error_stuck_on_ui_view_show")
    
    /// Sent when the app goes to the foreground as detected by `UIApplication.willEnterForegroundNotification`. It has an `is_cold_launch` boolean parameter
    static let APP_OPEN = EventAnalyticsModel("app_open", isTAInternalEvent: true)
    /// Sent when the app goes to the background as detected by `UIApplication.didEnterBackgroundNotification`. It also has parameters for the `last_parent_view` that was shown (aka no subviews).
    static let APP_CLOSE = EventAnalyticsModel("app_close", isTAInternalEvent: true)
    
    /// Parameters `from_version`, `to_version` (retrieved via `CFBundleShortVersionString` & `from_build`, `to_build` (retrieved via `CFBundleVersion`)
    static let APP_VERSION_UPDATE = EventAnalyticsModel("app_version_update", isTAInternalEvent: true)
    /// Parameters `from_version`, `to_version` (retrieved via `ProcessInfo.processInfo.operatingSystemVersion`)
    static let OS_VERSION_UPDATE = EventAnalyticsModel("os_version_update", isTAInternalEvent: true)
    
    /// Parameters `name`, the name of the engagement and all the last parent view shown is automatically added as parameters with `view_%`
    static let ENGAGEMENT = EventAnalyticsModel("engagement", isTAInternalEvent: true)
    /// Send this when you consider something the primary engagement of the app. This is sent alongside the usual `ENGAGEMENT` event with the same parameters
    static let ENGAGEMENT_PRIMARY = EventAnalyticsModel("engagement_primary", isTAInternalEvent: true)
    
    /// Sent when the onboarding starts and the very first screen is shown
    static let ONBOARDING_START = EventAnalyticsModel("onboarding_start", isTAInternalEvent: true)
    /// Sent when the onboarding is finished
    static let ONBOARDING_END = EventAnalyticsModel("onboarding_end", isTAInternalEvent: true)
    //// Sent when the account signup starts
    static let ACCOUNT_SIGNUP_START = EventAnalyticsModel("account_signup_start", isTAInternalEvent: true)
    //// Sent when the account signup ends
    static let ACCOUNT_SIGNUP_END = EventAnalyticsModel("account_signup_end", isTAInternalEvent: true)
    
    /// Parameters `placement`, `id` (optional)
    /// This also sends the `ui_view_show` event in the background with `name="paywall"` and `type=<placement>`
    static let PAYWALL_SHOW = EventAnalyticsModel("paywall_show", isTAInternalEvent: true)
    /// Parameters `placement`, `id` (optional)
    static let PAYWALL_CLOSE = EventAnalyticsModel("paywall_close", isTAInternalEvent: true)
    /// Parameters `button_name`, `product_identifier`, `paywall_placement`, `paywall_id` (optional),
    /// This also sends the `ui_button_tapped` event in the background with `name="purchase"`, `extra=<actualButtonName>`, `view_name=paywall`, `view_type=<paywallPlacement>`
    static let PAYWALL_PURCHASE_TAP = EventAnalyticsModel("paywall_purchase_tap", isTAInternalEvent: true)
    /// Purchase that happened once the user tried to purchase. TODO:// add those SKError events?
    static let ERROR_PAYWALL_PURCHASE = EventAnalyticsModel("error_paywall_purchase", isTAInternalEvent: true)
    /// The paywall couldn't be shown
    static let ERROR_PAYWALL_SHOW = EventAnalyticsModel("error_paywall_show", isTAInternalEvent: true)
    
    
    static let SUBSCRIPTION_START_PAID_PAY_AS_YOU_GO = EventAnalyticsModel("subscripton_start_paid_pay_as_you_go", isTAInternalEvent: true)
    static let SUBSCRIPTION_START_PAID_PAY_UP_FRONT = EventAnalyticsModel("subscripton_start_paid_pay_up_front", isTAInternalEvent: true)
    static let SUBSCRIPTION_START_TRIAL = EventAnalyticsModel("subscripton_star_trial", isTAInternalEvent: true)

    static let SUBSCRIPTION_START_PAID_REGULAR = EventAnalyticsModel("subscripton_start_paid_regular", isTAInternalEvent: true)

    static let SUBSCRIPTION_START = EventAnalyticsModel("subscripton_start", isTAInternalEvent: true)

    static let SUBSCRIPTION_RENEWAL = EventAnalyticsModel("subscripton_renewal", isTAInternalEvent: true)
    static let SUBSCRIPTION_TRIAL_CONVERTED_TO_PAID = EventAnalyticsModel("subscripton_trial_converted_to_paid", isTAInternalEvent: true)
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
    
    static let APP_VERSION = UserPropertyAnalyticsModel("app_version", isInternalUserProperty: true)
    static let DEVICE_LANGUAGE = UserPropertyAnalyticsModel("device_language", isInternalUserProperty: true)
    static let INSTALL_DEVICE_LANGUAGE = InstallUserPropertyAnalyticsModel("device_language", isTAInternalUserProperty: true)
    static let INSTALL_DEVICE_LANGUAGE2 = InstallUserPropertyAnalyticsModel("install_device_language", isTAInternalUserProperty: true)
    
    /// The date of the install, in ISO 8601 format (YYYY-MM-DD)
    static let INSTALL_DATE    = UserPropertyAnalyticsModel("install_date", isInternalUserProperty: true)
    /// The version of the app at install time
    static let INSTALL_VERSION = UserPropertyAnalyticsModel("install_version", isInternalUserProperty: true)
    /// The version of the platform/operating system
    static let INSTALL_PLATFORM_VERSION = UserPropertyAnalyticsModel("install_platform_version", isInternalUserProperty: true)
    /// If this is jailbroken at install time
    static let INSTALL_IS_JAILBROKEN = UserPropertyAnalyticsModel("install_is_jailbroken", isInternalUserProperty: true)
    /// The ui appearance at install time
    static let INSTALL_UI_APPEARANCE = UserPropertyAnalyticsModel("install_ui_appearance", isInternalUserProperty: true)
    /// The dynamic type at install time
    static let INSTALL_DYNAMIC_TYPE  = UserPropertyAnalyticsModel("install_dynamic_type", isInternalUserProperty: true)

    /// Ever increasing counter on each cold app launch, starting from 1 at first open.
    static let COLD_APP_LAUNCH_COUNT = UserPropertyAnalyticsModel("cold_app_launch_count", isInternalUserProperty: true)
    /// Ever increasing counter on each app open, starting from 1 at first open
    static let APP_OPEN_COUNT = UserPropertyAnalyticsModel("app_open_count", isInternalUserProperty: true)
    
    /// This is only shown for parent views (aka those with "parent view" set to nil). It's has multiple fields concatenated by `;` `view_name;view_type;group_name;group_order;group_stage`
    static let LAST_PARENT_VIEW_SHOWN = UserPropertyAnalyticsModel("last_parent_view_shown", isInternalUserProperty: true)
    
    // TODO: adi add Experiments or ABTesting mechanism that's dependent on feature flags
    // prefix all curent running experiments with `ab_%`
    
    /// If the variant is control/test.
    // TODO: move this out
//    static let INSTALL_VARIANT = AnalyticsUserProperty("install_variant")
    // TODO: Move this out
    /// The attribution network at install time
//    static let INSTALL_ATTR_NETWORK     = AnalyticsUserProperty("install_attr_network")
    /// The attribution campaign at install time
//    static let INSTALL_ATTR_CAMPAIGN    = AnalyticsUserProperty("install_attr_campaign")
}
