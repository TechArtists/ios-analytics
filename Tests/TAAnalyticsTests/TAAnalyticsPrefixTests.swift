//  TAAnalyticsTests.swift
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
import Testing
import Foundation
import TAAnalytics

class TAAnalyticsPrefixTests {

    let ta: TAAnalytics
    let unitTestConsumer: TAAnalyticsUnitTestConsumer
    
    init() {
        let mockUserDefaults = UserDefaults(suiteName: "TATests")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer()
        ta = TAAnalytics(config: TAAnalyticsConfig(analyticsVersion: "1", consumers: [unitTestConsumer],
                                                   userDefaults: mockUserDefaults,
                                           automaticallyTrackedEventsPrefixConfig: TAAnalyticsConfig.PrefixConfig(eventPrefix: "test_ev_", userPropertyPrefix: "test_up_"),
                                           manuallyTrackedEventsPrefixConfig: TAAnalyticsConfig.PrefixConfig(eventPrefix: "manual_test_ev_", userPropertyPrefix: "manual_test_up_")))
    }
    
    @Test
    func testManualUserPropertiesArePrefixedCorrectly() {
        let up = AnalyticsUserProperty("ta_test")
        
        ta.set(userProperty: up, to: "123")
        
        // below can fail if setting & getting aren't both prefixed
        #expect(ta.get(userProperty: up) == "123")
        
        #expect(ta.stringFromUserDefaults(forKey: "userProperty_manual_test_up_ta_test") == "123")
    }

    @Test
    func testInternalUserPropertiesArePrefixedCorrectly() {
        ta.set(userProperty: .APP_OPEN_COUNT, to: "123")
        #expect(ta.get(userProperty: .APP_OPEN_COUNT) == "123")
        
        #expect(ta.stringFromUserDefaults(forKey: "userProperty_test_up_\(AnalyticsUserProperty.APP_OPEN_COUNT.rawValue)") == "123")
    }

    @Test
    func testManualEventsArePrefixedCorrectly() {
        let ev = AnalyticsEvent("ta_test")
        
        ta.track(event: ev)

        // TODO: fix this, because the events are now sent async via the buffer
        #expect(unitTestConsumer.eventsSent[0].0.rawValue == "manual_test_ev_ta_test")
    }

    @Test
    func testInternalEventsArePrefixedCorrectly() {
        ta.track(event: .APP_OPEN)

        // TODO: fix this, because the events are now sent async via the buffer
        #expect(unitTestConsumer.eventsSent[0].0.rawValue == "manual_test_ev_\(AnalyticsEvent.APP_OPEN.rawValue)")
    }

    
}
