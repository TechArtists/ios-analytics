//  AnalyticsConsumer.swift
//  Created by Adi on 10/24/22.
//
//  Copyright (c) 2022 Overbase SRL (http://overbase.com/)
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

// Firebase/ OSLog/ Crashlytics

/// A concrete implementation of an Analytics Platform, that is able to log event & user properties
/// For example, there is an implementation that sends events to Firebase, another one that sends events to OSLog
///
/// You can create your own that can send events to any 3rd party.
open class AnalyticsConsumer {

    public init() {}
    
    /// Starts the consumer if it can for the required
    /// - Parameters:
    ///   - installType: installType
    ///   - userDefaults: user defaults to use
    ///   - overbaseAnalytics: if you do keep a reference to it, keep it `weak` and use it **after** this function has been called (to ensure that it was properly initialized)
    /// - Returns: `true` if it has been started, `false` otherwise
    open func maybeStartFor(installType: OverbaseAnalyticsConfig.InstallType, userDefaults: UserDefaults, overbaseAnalytics: OverbaseAnalyticsCompat) -> Bool {
        fatalError("not implemented")
    }
        
    
    /// Log the specific event
    open func log(event: AnalyticsEvent, params: [String: AnalyticsBaseParameterValue]?) {
        fatalError("not implemented")
    }
     
    /// Set the user property
    open func set(userProperty: AnalyticsUserProperty, to: String?) {
        fatalError("not implemented")
    }
}


/// If the consumer also support a user ID, though only setting it (e.g. Crashlytics)
public protocol AnalyticsConsumerWithWriteOnlyUserID: AnyObject {
    /// Swift forces us to also define a getter, but it will never be called for this protocol
    var userID: String? { get set }
}

/// If the consumer also support a user ID, both writing & reading it (e.g. Crashlytics)
public protocol AnalyticsConsumerWithReadWriteUserID: AnalyticsConsumerWithWriteOnlyUserID {
    var userID: String? { get set }
}

/// Some Analytics Consumers can also support a user pseudo ID (Firebase, mostly)
public protocol AnalyticsConsumerWithReadOnlyUserPseudoID: AnyObject {
    var userPseudoID: String { get }
}
