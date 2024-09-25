//  AnalyticsUserProperty.swift
//  Created by Adi on 10/24/22
//
//  Copyright (c) 2022 Tech Artists Agency SRL (http://TA.com/)
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

import Foundation

public final class AnalyticsInstallUserProperty: Hashable, Equatable, RawRepresentable {
   public let rawValue: String
    public let isInternalProperty: Bool
   
   public init(_ rawValue: String){
       self.rawValue = rawValue
       self.isInternalProperty = false
   }
   
   public init?(rawValue: String){
       self.rawValue = rawValue
       self.isInternalProperty = false
   }
    
    internal init(_ rawValue: String, isInternalProperty: Bool) {
        self.rawValue = rawValue
        self.isInternalProperty = isInternalProperty
    }
}

public final class AnalyticsUserProperty : Hashable, Equatable, RawRepresentable {
   
    public let rawValue: String
    public let isInternalProperty: Bool
    
    /// At most 24 alphanumeric characters or underscores
    /// Usually in snake_case, but it would be best to consult the BI for their preference.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
        self.isInternalProperty = false
    }
    /// At most 24 alphanumeric characters or underscores
    /// Usually in snake_case, but it would be best to consult the BI for their preference.
    public init?(rawValue: String) {
        self.rawValue = rawValue
        self.isInternalProperty = false
    }
    
    internal init(_ rawValue: String, isInternalProperty: Bool) {
        self.rawValue = rawValue
        self.isInternalProperty = isInternalProperty
    }
}

public final class TrimmedUserProperty {
    public let userProperty: AnalyticsUserProperty
    
    public init(_ rawValue: String){
        self.userProperty = AnalyticsUserProperty(rawValue)
    }
}
