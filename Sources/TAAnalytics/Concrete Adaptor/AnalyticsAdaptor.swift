//  AnalyticsAdaptor.swift
//  Created by Adi on 10/24/22.
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

/// `AnalyticsAdaptor` is a protocol that defines methods for starting an analytics adaptor, logging events, and setting user properties.
/// Classes that conform to this protocol will handle these operations for different analytics adaptors.
public protocol AnalyticsAdaptor<T> {
    
    associatedtype T
    
    /// Starts the adaptor if it can for the required
    /// - Parameters:
    ///   - installType: installType
    ///   - userDefaults: user defaults to use
    ///   - TAAnalytics: if you do keep a reference to it, keep it `weak` and use it **after** this function has been called (to ensure that it was properly initialized)
    /// - Returns: `true` if it has been started, `false` otherwise
    func startFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, taAnalytics: TAAnalytics) async throws
        
    /// Log event, enforces trimming before calling the adaptor-specific implementation.
    func track(trimmedEvent: EventAnalyticsModelTrimmed, params: [String: any AnalyticsBaseParameterValue]?)

    /// Set user property
    func set(trimmedUserProperty: UserPropertyAnalyticsModelTrimmed, to: String?)

    /// Adaptors should implement this to define how they trim the event.
    func trim(event: EventAnalyticsModel) -> EventAnalyticsModelTrimmed
    
    func trim(userProperty: UserPropertyAnalyticsModel) -> UserPropertyAnalyticsModelTrimmed
    
    var wrappedValue: T { get }
}

/// If the adaptor also support a user ID, both writing & reading it (e.g. Crashlytics)
public protocol AnalyticsAdaptorWithReadOnlyUserPseudoID {
    func getUserPseudoID() -> String?
    
}

/// If the adaptor also support a user ID, though only setting it (e.g. Crashlytics)
public protocol AnalyticsAdaptorWithWriteOnlyUserID: AnyObject {
    /// Swift forces us to also define a getter, but it will never be called for this protocol
    func set(userID: String?)
}

/// Some Analytics Adaptors can also support a user pseudo ID (Firebase, mostly)
public protocol AnalyticsAdaptorWithReadWriteUserID: AnyObject {
    func set(userID: String?)
    func getUserID() -> String?
}
