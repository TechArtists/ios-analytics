//  EventAnalyticsModel.swift
//  Created by Adi on 10/24/22
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

public final class EventAnalyticsModel: Hashable, Equatable, RawRepresentable {
    public let rawValue: String
    let isInternalEvent: Bool
    
    /// "firebase_", "google_", and "ga_" prefixes are reserved
    /// You can use spaces, snake_case or camelCase, best to consult the BIs for their preference.
    public init(_ rawValue: String){
        self.rawValue = rawValue
        self.isInternalEvent = false
    }
    /// "firebase_", "google_", and "ga_" prefixes are reserved
    /// You can use spaces, snake_case or camelCase, best to consult the BIs for their preference.
    public init?(rawValue: String) {
        self.rawValue = rawValue
        self.isInternalEvent = false
    }
    
    internal init(_ rawValue: String, isTAInternalEvent: Bool) {
        self.rawValue = rawValue
        self.isInternalEvent = isTAInternalEvent
    }
    
    public func eventBy(prefixing: String) -> EventAnalyticsModel {
        return .init(prefixing + rawValue, isTAInternalEvent: isInternalEvent)
    }
}

public final class EventAnalyticsModelTrimmed: Hashable, Equatable, RawRepresentable {
    public let rawValue: String
    
    public init(_ rawValue: String){
        self.rawValue = rawValue
    }
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
