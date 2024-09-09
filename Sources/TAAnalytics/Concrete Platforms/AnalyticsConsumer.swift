//  AnalyticsConsumer.swift
//  Created by Adi on 10/24/22.
//
//  Copyright (c) 2022 Tecj Artists Agenyc SRL (http://TA.com/)
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

/// `AnalyticsConsumer` is a protocol that defines methods for starting an analytics consumer, logging events, and setting user properties.
/// Classes that conform to this protocol will handle these operations for different analytics platforms.
public protocol AnalyticsConsumer {
    /// Starts the consumer if it can for the required
    /// - Parameters:
    ///   - installType: installType
    ///   - userDefaults: user defaults to use
    ///   - TAAnalytics: if you do keep a reference to it, keep it `weak` and use it **after** this function has been called (to ensure that it was properly initialized)
    /// - Returns: `true` if it has been started, `false` otherwise
    func maybeStartFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, TAAnalytics: TAAnalytics) -> Bool
        
    
    /// Log the specific event
    func log(event: AnalyticsEvent, params: [String: AnalyticsBaseParameterValue]?)
     
    /// Set the user property
    func set(userProperty: AnalyticsUserProperty, to: String?)
}


/// If the consumer also support a user ID, though only setting it (e.g. Crashlytics)
public protocol AnalyticsConsumerWithWriteOnlyUserID: AnyObject {
    /// Swift forces us to also define a getter, but it will never be called for this protocol
    func set(usertID: String?)
}

/// If the consumer also support a user ID, both writing & reading it (e.g. Crashlytics)
public protocol AnalyticsConsumerWithReadWriteUserID: AnalyticsConsumerWithWriteOnlyUserID {
    func getUserID() -> String?
}

/// Some Analytics Consumers can also support a user pseudo ID (Firebase, mostly)
public protocol AnalyticsConsumerWithReadOnlyUserPseudoID: AnyObject {
    func set(usertID: String?)
    func getUserID() -> String?
}
