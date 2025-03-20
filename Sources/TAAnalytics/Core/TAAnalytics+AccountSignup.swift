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

public enum TASignupMethodType: CustomStringConvertible {
    case email
    case apple
    case google
    case facebook
    case custom(String)
    
    public var description: String {
        switch self {
        case .email: return "email"
        case .apple: return "apple"
        case .google: return "google"
        case .facebook: return "facebook"
        case .custom(let string):
            return string
        }
    }
}

/// Defines specific events for showing views & tapping buttons
public protocol TAAnalyticsAccountSignupProtocol: TAAnalyticsBaseProtocol {
    
    /// Sends an `onboarding_enter` event with these parameters:
    func trackAccountSignupEnter(method: TASignupMethodType?, extraParams: [String: (any AnalyticsBaseParameterValue)]?)

    /// Sends an `onboarding_enter` event with these parameters:
    func trackAccountSignupExit(method: TASignupMethodType, extraParams: [String: (any AnalyticsBaseParameterValue)]?)
}

// MARK: - Default Implementations

extension TAAnalytics: TAAnalyticsAccountSignupProtocol {

    public func trackAccountSignupEnter(method: TASignupMethodType?, extraParams: [String: (any AnalyticsBaseParameterValue)]?){
        var params = [String: (any AnalyticsBaseParameterValue)]()
        if let method = method {
            params["method"] = method.description
        }
        
        extraParams?.forEach({ key, value in params[key] = value })
        track(event: .ACCOUNT_SIGNUP_ENTER, params: params, logCondition: .logAlways)
    }
    

    public func trackAccountSignupExit(method: TASignupMethodType, extraParams: [String: (any AnalyticsBaseParameterValue)]?){
        var params = [String: (any AnalyticsBaseParameterValue)]()
        params["method"] = method.description
        
        extraParams?.forEach({ key, value in params[key] = value })
        track(event: .ACCOUNT_SIGNUP_EXIT, params: params, logCondition: .logAlways)
    }

}
