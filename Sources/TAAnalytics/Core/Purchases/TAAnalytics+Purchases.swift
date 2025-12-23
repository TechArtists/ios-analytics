//  TAAnalytics+Purchases.swift
//  Created by Robert Tataru
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

// MARK: - Purchase Analytics

/// Represents analytics data for in-app purchases
public protocol TAPurchaseAnalytics {
    var paywall: TAPaywallAnalytics { get }
    var productID: String { get }
    var price: Float { get }
    var currency: String { get }
}

/// Default implementation of TAPurchaseAnalytics
public struct TAPurchaseAnalyticsImpl: TAPurchaseAnalytics {
    public var paywall: any TAPaywallAnalytics
    public var productID: String
    public var price: Float
    public var currency: String
    
    public init(paywall: any TAPaywallAnalytics, productID: String, price: Float, currency: String) {
        self.paywall = paywall
        self.productID = productID
        self.price = price
        self.currency = currency
    }
}

/// Protocol defining purchase tracking methods
public protocol TAAnalyticsPurchasesProtocol: TAAnalyticsBaseProtocol {
    
    /// Sends a `purchase_non_consumable_one_time` event with parameters:
    ///
    ///      placement: String
    ///      product_id: String
    ///      value: Float
    ///      price: Float
    ///      currency: String
    ///      quantity: 1
    ///      paywall_id: String?
    ///      paywall_name: String?
    ///
    /// It also sends a `purchase_new` event alongside it.
    /// - Parameters:
    ///   - purchase: the purchase analytics data containing product details and paywall info
    func trackPurchaseNonConsumableOneTime(_ purchase: TAPurchaseAnalytics)
    
    /// Sends a `purchase_consumable` event with parameters:
    ///
    ///      placement: String
    ///      product_id: String
    ///      value: Float
    ///      price: Float
    ///      currency: String
    ///      quantity: 1
    ///      paywall_id: String?
    ///      paywall_name: String?
    ///
    /// It also sends a `purchase_new` event alongside it.
    /// - Parameters:
    ///   - purchase: the purchase analytics data containing product details and paywall info
    func trackPurchaseConsumable(_ purchase: TAPurchaseAnalytics)
    
    /// DO NOT USE this directly, instead use `trackPurchaseNonConsumableOneTime` or `trackPurchaseConsumable`
    /// Sends a `purchase_new` event with parameters:
    ///
    ///      placement: String
    ///      product_id: String
    ///      value: Float
    ///      price: Float
    ///      currency: String
    ///      quantity: 1
    ///      paywall_id: String?
    ///      paywall_name: String?
    ///
    /// - Parameters:
    ///   - purchase: the purchase analytics data containing product details and paywall info
    func trackPurchaseNew(_ purchase: TAPurchaseAnalytics)
}

// MARK: - Default Implementations

extension TAAnalytics: TAAnalyticsPurchasesProtocol {
    
    public func trackPurchaseNonConsumableOneTime(_ purchase: TAPurchaseAnalytics) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        addPurchaseParameters(to: &params, purchase: purchase)
        
        track(event: .PURCHASE_NON_CONSUMABLE_ONE_TIME, params: params, logCondition: .logAlways)
        trackPurchaseNew(purchase)
    }
    
    public func trackPurchaseConsumable(_ purchase: TAPurchaseAnalytics) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        addPurchaseParameters(to: &params, purchase: purchase)
        
        track(event: .PURCHASE_CONSUMABLE, params: params, logCondition: .logAlways)
        trackPurchaseNew(purchase)
    }
    
    public func trackPurchaseNew(_ purchase: TAPurchaseAnalytics) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        addPurchaseParameters(to: &params, purchase: purchase)
        
        track(event: .PURCHASE_NEW, params: params, logCondition: .logAlways)
    }
    
    private func addPurchaseParameters(to params: inout [String: (any AnalyticsBaseParameterValue)], purchase: TAPurchaseAnalytics) {
        params["placement"] = purchase.paywall.analyticsPlacement
        params["product_id"] = purchase.productID
        params["value"] = purchase.price
        params["price"] = purchase.price
        params["currency"] = purchase.currency
        params["quantity"] = 1
        
        if let id = purchase.paywall.anayticsID {
            params["paywall_id"] = id
        }
        if let name = purchase.paywall.analyticsName {
            params["paywall_name"] = name
        }
    }
}