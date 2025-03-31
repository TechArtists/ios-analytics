//  TAAnalytics+Subscriptions.swift
//  Created by Adi on 2025-03-28
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
public enum TASubscriptionType: CustomStringConvertible, Sendable {
    case trial
    case paidPayAsYouGo
    case paidPayUpFront
    case paidRegular
    case other(String)
    
    public var description: String {
        switch self {
        case .trial: return "trial"
        case .paidPayAsYouGo: return "paid intro pay as you go"
        case .paidPayUpFront: return "paid intro pay up front"
        case .paidRegular: return "paid regular"
        case .other(let s): return "other \(s)"
        }
    }
}

public protocol TASubscriptionStartAnalytics {
    var subscriptionType: TASubscriptionType { get }
    var paywall: TAPaywallAnalytics { get }
    var productID: String { get }
    var price: Float { get }
    var currency: String { get }
}

public struct TASubscriptionStartAnalyticsImpl: TASubscriptionStartAnalytics {
    public var subscriptionType: TASubscriptionType
    public var paywall: any TAPaywallAnalytics
    public var productID: String
    public var price: Float
    public var currency: String
    
    public init(subscriptionType: TASubscriptionType, paywall: any TAPaywallAnalytics, productID: String, price: Float, currency: String) {
        self.subscriptionType = subscriptionType
        self.paywall = paywall
        self.productID = productID
        self.price = price
        self.currency = currency
    }
}

/// Defines specific events for showing views & tapping buttons
public protocol TAAnalyticsSubscriptionsProtocol: TAAnalyticsBaseProtocol {
    
    /// Sends an `subscription_start_intro` event with these parameters:
    ///
    ///      product_id: String
    ///      subscription_type: String = all except .paidRegular
    ///      placement: String
    ///      paywall_id: String?
    ///      paywall_name: String?
    ///
    /// It also send a `subscription_start_new` event alongside it.
    /// - Parameters:
    ///   - paywall: the placement that triggered the paywall
    ///   - type: the type of subscription intro started
    func trackSubscriptionStartIntro(_ sub: TASubscriptionStartAnalytics)

    /// Sends an `subscription_start_paid_regular` event with these parameters:
    ///
    ///      product_id: String
    ///      subscription_type: String = .paidRegular always
    ///      placement: String
    ///      paywall_id: String?
    ///      paywall_name: String?
    ///
    /// It also send a `subscription_start_new` event alongside it.
    /// - Parameters:
    ///   - paywall: the placement that triggered the paywall
    func trackSubscriptionStartPaidRegular(_ sub: TASubscriptionStartAnalytics)

    /// DO NOT USE this directly, instead use `trackSubscriptionStartIntro` or `trackSubscriptionStartPaidRegular`
    /// Sends an `subscription_start_new` event with these parameters:
    ///
    ///      product_id: String
    ///      subscription_type: String = .paidRegular always
    ///      placement: String
    ///      paywall_id: String?
    ///      paywall_name: String?
    ///
    /// - Parameters:
    ///   - paywall: the placement that triggered the paywall
    func trackSubscriptionStartNew(_ sub: TASubscriptionStartAnalytics)

    /// Sends an `subscription_restore` event with these parameters:
    ///
    ///      product_id: String
    ///      subscription_type: String
    ///      placement: String
    ///      paywall_id: String?
    ///      paywall_name: String?
    ///
    /// - Parameters:
    ///   - paywall: the placement that triggered the paywall
    func trackSubscriptionRestore(_ sub: TASubscriptionStartAnalytics)

}

// MARK: - Default Implementations

extension TAAnalytics: TAAnalyticsSubscriptionsProtocol {

    public func trackSubscriptionStartIntro(_ sub: TASubscriptionStartAnalytics){
        var params = [String: (any AnalyticsBaseParameterValue)]()
        addParameters(to: &params, sub: sub)

        track(event: .SUBSCRIPTION_START_INTRO, params: params, logCondition: .logAlways)
        trackSubscriptionStartNew(sub)
    }
    

    public func trackSubscriptionStartPaidRegular(_ sub: TASubscriptionStartAnalytics) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        addParameters(to: &params, sub: sub)

        track(event: .SUBSCRIPTION_START_PAID_REGULAR, params: params, logCondition: .logAlways)
        trackSubscriptionStartNew(sub)
    }
    
    public func trackSubscriptionStartNew(_ sub: TASubscriptionStartAnalytics) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        addParameters(to: &params, sub: sub)
        
        track(event: .SUBSCRIPTION_START_NEW, params: params, logCondition: .logAlways)
    }
    
    public func trackSubscriptionRestore(_ sub: TASubscriptionStartAnalytics) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        addParameters(to: &params, sub: sub)

        track(event: .SUBSCRIPTION_RESTORE, params: params, logCondition: .logAlways)
    }
    
    private func addParameters(to params: inout [String: (any AnalyticsBaseParameterValue)], sub: TASubscriptionStartAnalytics) {
        
        params["product_id"] = sub.productID
        params["type"] = sub.subscriptionType.description
        params["placement"] = sub.paywall.analyticsPlacement

        params["value"] = sub.price
        params["price"] = sub.price
        params["currency"] = sub.currency
        params["quantity"] = 1

        if let id = sub.paywall.anayticsID {
            params["paywall_id"] = id
        }
        if let name = sub.paywall.analyticsName {
            params["paywall_name"] = name
        }
    }
}
