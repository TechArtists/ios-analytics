//  TAAnalytics+UI.swift
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

/// Defines specific events for showing views & tapping buttons
public protocol TAAnalyticsPaywallsProtocol: TAAnalyticsBaseProtocol {
    
    /// Sends an `paywall_show` event with these parameters:
    ///
    ///      placement: String
    ///      id: String?
    ///
    /// It also sends a `ui_view_show` event with `name="paywall"` and `type=<placement>`
    ///
    /// - Parameters:
    ///   - placement: the placement that triggered the paywall
    ///   - id: the id of the paywall, optional. For example, you might have 2 different types of paywalls that are shown in an A/B test, each with their own ID.
    func trackPaywallShow(placement: String, id: String?)

    /// Sends an `paywall_close` event with these parameters:
    ///
    ///      placement: String
    ///      id: String?
    ///
    /// - Parameters:
    ///   - placement: the placement that triggered the paywall
    ///   - id: the id of the paywall, optional. For example, you might have 2 different types of paywalls that are shown in an A/B test, each with their own ID.
    func trackPaywallClose(placement: String, id: String?)
    
    /// Sends an `paywall_purchase_tap` event with these parameters:
    ///
    ///      button_name: String
    ///      paywall_placement: String
    ///      paywall_id: String?
    ///      product_identifier: String
    ///
    /// It also sends a `ui_button_tap` event with `name="purchase`, `extra=<buttonName>`, `view_name="paywall"`, `view_type=<placement>`
    /// - Parameters:
    ///   - buttonName: the name of the button that was pressed. Usualy, dont' send the localized value, but send the English variant (e.g. "Try free before subscribing" vs "Subscribe Now")
    ///   - productIdentifier: the product identifier of the in app purchase/subscription users are trying to purchase
    ///   - paywallPlacement: the placement that triggered the paywall
    ///   - paywallID: the id of the paywall, optional. For example, you might have 2 different types of paywalls that are shown in an A/B test, each with their own ID.
    func trackPaywallPurchaseTap(buttonName: String, productIdentifier: String, paywallPlacement: String, paywallID: String?)

    /// Sends an `error_paywall_purchase` event when the purchase couldn't be completed because of an error with these parameters:
    ///
    ///      error_domain: String?
    ///      error_code: String?
    ///      error_description: String?
    ///      paywall_placement: String
    ///      paywall_id: String?
    ///      product_identifier: String
    ///
    /// - Parameters:
    ///   - error: the error with more details about why the purchase failed
    ///   - productIdentifier: the product identifier of the in app purchase/subscription users are trying to purchase
    ///   - paywallPlacement: the placement that triggered the paywall
    ///   - paywallID: the id of the paywall, optional. For example, you might have 2 different types of paywalls that are shown in an A/B test, each with their own ID.
    func trackErrorPaywallPurchase(error: Error?, productIdentifier: String, paywallPlacement: String, paywallID: String?)

    /// Sends an `error_paywall_show` event when the paywall couldn't be shown with these parameters:
    ///
    ///      error_domain: String?
    ///      error_code: String?
    ///      error_description: String?
    ///      paywall_placement: String
    ///      paywall_id: String?
    ///
    /// - Parameters:
    ///   - error: the error with more details about why the paywall couldn't be shown
    ///   - paywallPlacement: the placement that triggered the paywall
    ///   - paywallID: the id of the paywall, optional. For example, you might have 2 different types of paywalls that are shown in an A/B test, each with their own ID.
    func trackErrorPaywallShow(error: Error?, paywallPlacement: String, paywallID: String?)
}

// MARK: - Default Implementations

extension TAAnalytics: TAAnalyticsPaywallsProtocol {

    public func trackPaywallShow(placement: String, id: String?) {
        var params = [String: (any AnalyticsBaseParameterValue)]()

        params["placement"] = placement
        if let id = id {
            params["id"] = id
        }

        track(event: .PAYWALL_SHOW, params: params, logCondition: .logAlways)
        track(viewShow: ViewAnalyticsModel(name: "paywall", type: placement))
    }
    
    public func trackPaywallClose(placement: String, id: String?) {
        var params = [String: (any AnalyticsBaseParameterValue)]()

        params["placement"] = placement
        if let id = id {
            params["id"] = id
        }

        track(event: .PAYWALL_CLOSE, params: params, logCondition: .logAlways)
    }

    public func trackPaywallPurchaseTap(buttonName: String, productIdentifier: String, paywallPlacement: String, paywallID: String?) {
        var params = [String: (any AnalyticsBaseParameterValue)]()

        params["button_name"] = buttonName
        params["product_identifier"] = productIdentifier
        params["paywall_placement"] = paywallPlacement
        if let id = paywallID {
            params["paywall_id"] = id
        }

        track(event: .PAYWALL_PURCHASE_TAP, params: params, logCondition: .logAlways)
        track(buttonTap: "purchase", onView: ViewAnalyticsModel(name: "paywall", type: paywallPlacement), extra: buttonName, index: nil)
    }

    public func trackErrorPaywallPurchase(error: Error?, productIdentifier: String, paywallPlacement: String, paywallID: String?) {
        var params = [String: (any AnalyticsBaseParameterValue)]()

        if let error = error {
            let nserror = error as NSError
            params["error_domain"] = nserror.domain
            params["error_code"] = nserror.code
            params["error_description"] = nserror.localizedDescription
        }

        params["paywall_placement"] = paywallPlacement
        if let id = paywallID {
            params["paywall_id"] = id
        }
        params["product_identifier"] = productIdentifier

        track(event: .ERROR_PAYWALL_PURCHASE, params: params, logCondition: .logAlways)
        trackErrorEvent(eventSuffix: "paywall_purchase", error: error, extraParams: params)
    }

    public func trackErrorPaywallShow(error: Error?, paywallPlacement: String, paywallID: String?) {
        var params = [String: (any AnalyticsBaseParameterValue)]()

        if let error = error {
            let nserror = error as NSError
            params["domain"] = nserror.domain
            params["code"] = nserror.code
            params["description"] = nserror.localizedDescription
        }

        params["paywall_placement"] = paywallPlacement
        if let id = paywallID {
            params["paywall_id"] = id
        }

        track(event: .ERROR_PAYWALL_PURCHASE, params: params, logCondition: .logAlways)
        trackErrorEvent(eventSuffix: "paywall_purchase", error: error, extraParams: params)
    }

    
}
