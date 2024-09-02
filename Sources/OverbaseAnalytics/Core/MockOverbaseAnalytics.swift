//  MockOverbaseAnalytics.swift
//
//  Created by Adi on 10/25/22.
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

/// Very basic implementation of `OvebaseAnalyticsProtocol` that can be used in unit tests:
///
///     let mockAnalytics = MockOverbaseAnalyticsPlatform()
///     let foo = Foo(analytics: mockAnalytics)
///     foo.doStuff()
///
///     XCTAssertEqual(foo.stuffItDid, 42)
///     XCTAssertEqual(mockAnalytics.eventsSent.last?.event, AnalyticsEvent.EVENT_I_EXPECTED)
public class MockOverbaseAnalyticsPlatform : OverbaseAnalyticsProtocol {
    
    public var eventsSent = [(event: AnalyticsEvent, params: [String: AnalyticsBaseParameterValue])]()
    public var userPropertiesSet = [AnalyticsUserProperty: String]()
    
    public init() {
    }
    
    public var currentProcessType: OverbaseAnalyticsConfig.ProcessType {
        return .app
    }

    public func start(beforeLoggingFirstOpenCompletion: (() -> ())? = nil,
                      shouldLogFirstOpen: Bool = true,
                      firstOpenParameterCallback: (() -> [String: AnalyticsBaseParameterValue]?)? = nil ) {
        Self.staticLoadCount += 1
        
        beforeLoggingFirstOpenCompletion?()
        if shouldLogFirstOpen {
            let params = firstOpenParameterCallback?()
            self.maybeLogOverbaseFirstOpen(paramsCallback: { return params })
        }
    }

    public func log(event: AnalyticsEvent, params: [String : AnalyticsBaseParameterValue]?, logCondition: EventLogCondition) {
        eventsSent.append((event, params ?? [:]))
    }
        
    public func set(userProperty: AnalyticsUserProperty, to: String?) {
        guard let to = to else { return }
        userPropertiesSet[userProperty] = to
    }

    public func get(userProperty: AnalyticsUserProperty) -> String? {
        return userPropertiesSet[userProperty]
    }

    private static var staticLoadCount = 0
    public var loadCount: Int { return Self.staticLoadCount }
    
    public var installAgeRelativeTime: Int? = nil
    
    public var installAgeLocalizedCalendar: Int? = nil
    
    @discardableResult public func maybeLogOverbaseFirstOpen(paramsCallback: () -> [String : AnalyticsBaseParameterValue]?) -> Bool {
        let params = paramsCallback()
        log(event: .FIRST_OPEN, params: params, logCondition: .logOnlyOncePerLifetime)
        return true
    }
    
    public var userPseudoID: String? = UUID().uuidString
    
    public var userID: String? = nil
    


}
