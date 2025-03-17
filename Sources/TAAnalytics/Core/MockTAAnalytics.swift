//  MockTAAnalytics.swift
//
//  Created by Adi on 10/25/22.
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
import UIKit

/// Very basic implementation of `OvebaseAnalyticsProtocol` that can be used in unit tests:
///
///     let mockAnalytics = MockTAAnalytics()
///     let foo = Foo(analytics: mockAnalytics)
///     foo.doStuff()
///
///     XCTAssertEqual(foo.stuffItDid, 42)
///     XCTAssertEqual(mockAnalytics.eventsSent.last?.event, EventAnalyticsModel.EVENT_I_EXPECTED)
public class MockTAAnalytics : TAAnalyticsProtocol {
    
    public var eventsSent = [(event: EventAnalyticsModel, params: [String: (any AnalyticsBaseParameterValue)?])]()
    public var userPropertiesSet = [UserPropertyAnalyticsModel: String]()
    public var lastParentViewShown: ViewAnalyticsModel?
    public var stuckTimer: Timer?
    public var correctionStuckTimer: Timer?

    public init() {}
    
    public var currentProcessType: TAAnalyticsConfig.ProcessType {
        return .app
    }

    public func start(customInstallUserPropertiesCompletion: (() -> ())? = nil,
                      shouldLogFirstOpen: Bool = true,
                      firstOpenParameterCallback: (() -> [String: (any AnalyticsBaseParameterValue)]?)? = nil ) {
        Self.staticLoadCount += 1
        
        customInstallUserPropertiesCompletion?()
        if shouldLogFirstOpen {
            let params = firstOpenParameterCallback?()
            self.maybeLogTAFirstOpen(paramsCallback: { return params })
        }
    }

    public func track(event: EventAnalyticsModel, params: [String : (any AnalyticsBaseParameterValue)?]? = nil, logCondition: EventLogCondition = .logAlways) {
        eventsSent.append((event, params ?? [:]))
    }
        
    public func set(userProperty: UserPropertyAnalyticsModel, to: String?) {
        guard let to = to else { return }
        userPropertiesSet[userProperty] = to
    }

    public func get(userProperty: UserPropertyAnalyticsModel) -> String? {
        return userPropertiesSet[userProperty]
    }

    private static var staticLoadCount = 0
    public var loadCount: Int { return Self.staticLoadCount }
    
    public var installAgeRelativeTime: Int? = nil
    
    public var installAgeLocalizedCalendar: Int? = nil
    
    @discardableResult public func maybeLogTAFirstOpen(paramsCallback: () -> [String : (any AnalyticsBaseParameterValue)]?) -> Bool {
        let params = paramsCallback()
        track(event: .FIRST_OPEN, params: params, logCondition: .logOnlyOncePerLifetime)
        return true
    }
    
    public var userPseudoID: String? = UUID().uuidString
    
    public var userID: String? = nil
    
    public func addAppLifecycleObservers() {
        
    }
    
    public func track(viewShow view: ViewAnalyticsModel, stuckTimer: TimeInterval) {
        
    }
}
