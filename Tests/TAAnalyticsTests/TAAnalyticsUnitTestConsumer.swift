//
//  File.swift
//  TAAnalytics
//
//  Created by Adi on 10/20/24.
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
import TAAnalytics

class TAAnalyticsUnitTestConsumer: AnalyticsConsumer {
    
    public var eventsSent = [(event: EventAnalyticsModelTrimmed, params: [String: (any AnalyticsBaseParameterValue)?])]()
    public var userPropertiesSet = [UserPropertyAnalyticsModelTrimmed: String]()
    
    public typealias T = TAAnalyticsUnitTestConsumer
    public var wrappedValue: Self {
        self
    }

    private let eventTrimLength: Int
    private let userPropertyTrimLength: Int
     
    init(eventTrimLength: Int = 40, userPropertyTrimLength: Int = 24) {
        self.eventTrimLength = eventTrimLength
        self.userPropertyTrimLength = userPropertyTrimLength
    }
    
    func startFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, TAAnalytics: TAAnalytics) async throws {
    }
    
    func track(trimmedEvent: EventAnalyticsModelTrimmed, params: [String : any AnalyticsBaseParameterValue]?) {
        eventsSent.append((trimmedEvent, params ?? [:]))
    }
    
    func set(trimmedUserProperty: UserPropertyAnalyticsModelTrimmed, to: String?) {
        guard let to = to else { return }
        userPropertiesSet[trimmedUserProperty] = to
    }
    
    func trim(event: EventAnalyticsModel) -> EventAnalyticsModelTrimmed {
        EventAnalyticsModelTrimmed(String(event.rawValue.prefix(eventTrimLength)))
    }
    
    public func trim(userProperty: UserPropertyAnalyticsModel) -> UserPropertyAnalyticsModelTrimmed {
        UserPropertyAnalyticsModelTrimmed(String(userProperty.rawValue.prefix(userPropertyTrimLength)))
    }
        
    
}
