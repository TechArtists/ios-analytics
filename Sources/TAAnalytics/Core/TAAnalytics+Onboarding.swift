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
public protocol TAAnalyticsOnboardingProtocol: TAAnalyticsBaseProtocol {
    
    /// Sends an `onboarding_enter` event with these parameters:
    func trackOnboardingEnter(extraParams: [String: (any AnalyticsBaseParameterValue)]?)

    /// Sends an `onboarding_enter` event with these parameters:
    func trackOnboardingExit(extraParams: [String: (any AnalyticsBaseParameterValue)]?)
}

// MARK: - Default Implementations

extension TAAnalytics: TAAnalyticsOnboardingProtocol {

    public func trackOnboardingEnter(extraParams: [String: (any AnalyticsBaseParameterValue)]?){
        track(event: .ONBOARDING_ENTER, params: extraParams, logCondition: .logAlways)
    }
    

    public func trackOnboardingExit(extraParams: [String: (any AnalyticsBaseParameterValue)]?){
        track(event: .ONBOARDING_EXIT, params: extraParams, logCondition: .logAlways)
    }

}
