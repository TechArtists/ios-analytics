//  TAAnalytics+Subscriptions.swift
//  Created by Adi on 2025-03-21
//
//  Copyright (c) 2025 Tech Artists Agency SRL
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
public enum TAPaywallExitReason: CustomStringConvertible {
    case closedPaywall
    case cancelledPaymentConfirmation
    case newSubscription
    case restoredSubscription
    case other(String)
    
    public var description: String {
        switch self {
        case .closedPaywall: return "closed paywall"
        case .cancelledPaymentConfirmation: return "cancelled payment confirmation"
        case .newSubscription: return "new subscription"
        case .restoredSubscription: return "restored subscription"
        case .other(let s): return "other \(s)"
        }
    }
}

public protocol TAPaywallAnalytics {
    /// the placement that triggered the paywall
    var analyticsPlacement: String { get }

    /// the id of the paywall, optional. For example, you might have 2 different types of paywalls that are shown in an A/B test, each with their own ID.
    var anayticsID: String? { get }

    /// the name of the paywall, optional. It needs to be paired with the ID, but it's usually more human readable
    var analyticsName: String? { get }
}

public struct TAPaywallAnalyticsImpl: TAPaywallAnalytics {
    public var analyticsPlacement: String
    public var anayticsID: String?
    public var analyticsName: String?
    
    public init(analyticsPlacement: String, anayticsID: String? = nil, analyticsName: String? = nil) {
        self.analyticsPlacement = analyticsPlacement
        self.anayticsID = anayticsID
        self.analyticsName = analyticsName
    }
}

/// Defines specific events for showing views & tapping buttons
public protocol TAAnalyticsPaywallsProtocol: TAAnalyticsBaseProtocol {
    
    /// Sends an `paywall_show` event with these parameters:
    ///
    ///      placement: String
    ///      id: String?
    ///      name: String?
    ///
    /// It also sends a `ui_view_show` event with `name="paywall"` and `type=<placement>`
    ///
    /// - Parameters:
    func trackPaywallEnter(paywall: TAPaywallAnalytics)

    /// Sends an `paywall_close` event with these parameters:
    ///
    ///      placement: String
    ///      id: String?
    ///      name: String?
    ///      reason: String
    ///
    /// - Parameters:
    ///   - paywall: the paywall
    ///   - id: the id of the paywall, optional. For example, you might have 2 different types of paywalls that are shown in an A/B test, each with their own ID.
    func trackPaywallExit(paywall: TAPaywallAnalytics, reason:TAPaywallExitReason)
    
    /// Sends an `paywall_purchase_tap` event with these parameters:
    ///
    ///      button_name: String
    ///      paywall_placement: String
    ///      paywall_id: String?
    ///      product_id: String
    ///
    /// It also sends a `ui_button_tap` event with `name="subscribe"`, `extra=<buttonName>`, `view_name="paywall"`, `view_type=<placement>`
    /// - Parameters:
    ///   - buttonName: the name of the button that was pressed. Usualy, dont' send the localized value, but send the English variant (e.g. "Try free before subscribing" vs "Subscribe Now")
    ///   - productIdentifier: the product identifier of the in app purchase/subscription users are trying to purchase
    ///   - placement: the placement that triggered the paywall
    ///   - paywallID: the id of the paywall, optional. For example, you might have 2 different types of paywalls that are shown in an A/B test, each with their own ID.
    func trackPaywallPurchaseTap(buttonName: String, productIdentifier: String, paywall: TAPaywallAnalytics)

}

// MARK: - Default Implementations

extension TAAnalytics: TAAnalyticsPaywallsProtocol {

    public func trackPaywallEnter(paywall: TAPaywallAnalytics) {
        var params = [String: (any AnalyticsBaseParameterValue)]()

        params["placement"] = paywall.analyticsPlacement
        if let id = paywall.anayticsID {
            params["id"] = paywall.anayticsID
        }
        if let name = paywall.analyticsName {
            params["name"] = paywall.analyticsName
        }

        track(event: .PAYWALL_ENTER, params: params, logCondition: .logAlways)
        track(viewShow: ViewAnalyticsModel(name: "paywall", type: paywall.analyticsPlacement))
    }
    
    public func trackPaywallExit(paywall: TAPaywallAnalytics, reason:TAPaywallExitReason){
        var params = [String: (any AnalyticsBaseParameterValue)]()

        params["placement"] = paywall.analyticsPlacement
        params["reason"] = reason.description
        
        if let id = paywall.anayticsID {
            params["id"] = paywall.anayticsID
        }
        if let name = paywall.analyticsName {
            params["name"] = paywall.analyticsName
        }

        track(event: .PAYWALL_EXIT, params: params, logCondition: .logAlways)
    }


    public func trackPaywallPurchaseTap(buttonName: String, productIdentifier: String, paywall: TAPaywallAnalytics) {
        
        var params = [String: (any AnalyticsBaseParameterValue)]()

        params["button_name"] = buttonName
        params["product_id"] = productIdentifier
        params["placement"] = paywall.analyticsPlacement
        if let id = paywall.anayticsID {
            params["paywall_id"] = paywall.anayticsID
        }
        if let name = paywall.analyticsName {
            params["paywall_name"] = paywall.analyticsName
        }

        track(event: .PAYWALL_PURCHASE_TAP, params: params, logCondition: .logAlways)
        track(buttonTap: buttonName, onView: ViewAnalyticsModel(name: "paywall", type: paywall.analyticsPlacement), extra: nil, index: nil)
    }
    
}
