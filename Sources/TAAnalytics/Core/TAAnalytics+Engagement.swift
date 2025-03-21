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
public protocol TAAnalyticsEngagementProtocol: TAAnalyticsBaseProtocol {
    
    /// Sends an `engagement` event with these parameters:
    ///
    ///      name: String
    ///      view_{name, type, group_name, group_order, group_stage}: String?
    ///
    /// - Parameters:
    ///   - engagement: the name for this engagement (e.g. for a fitness app it can be "start workout" or "end workout")
    func track(engagement: String)

    /// Sends both `engagement_primary` & `engagement` events with these parameters:
    ///
    ///      name: String
    ///      view_{name, type, group_name, group_order, group_stage}: String?
    ///
    /// - Parameters:
    ///   - engagement: the name for this engagement (e.g. for a fitness app it can be "start workout" or "end workout")
    func track(engagementPrimary: String)
}

// MARK: - Default Implementations

extension TAAnalytics: TAAnalyticsEngagementProtocol {

    public func track(engagement: String){
        var params = [String: (any AnalyticsBaseParameterValue)]()
        params["name"] = engagement

        if let view = self.lastViewShow {
            addParameters(for: view, to: &params, prefix: "view_")
        }
        track(event: .ENGAGEMENT, params: params, logCondition: .logAlways)
    }
    
    public func track(engagementPrimary: String){
        var params = [String: (any AnalyticsBaseParameterValue)]()
        params["name"] = engagementPrimary

        if let view = self.lastViewShow {
            addParameters(for: view, to: &params, prefix: "view_")
        }
        track(event: .ENGAGEMENT, params: params, logCondition: .logAlways)
        track(event: .ENGAGEMENT_PRIMARY, params: params, logCondition: .logAlways)
    }

}
