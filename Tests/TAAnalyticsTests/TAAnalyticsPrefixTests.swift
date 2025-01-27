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
@testable import TAAnalytics

class TAAnalyticsPrefixTests {

    let analytics: TAAnalytics
    let unitTestConsumer: TAAnalyticsUnitTestConsumer
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATestsPrefix")
        let mockUserDefaults = UserDefaults(suiteName: "TATestsPrefix")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer()
        analytics = TAAnalytics(
            config: TAAnalyticsConfig(
                analyticsVersion: "1",
                consumers: [unitTestConsumer],
                userDefaults: mockUserDefaults,
                automaticallyTrackedEventsPrefixConfig: TAAnalyticsConfig.PrefixConfig(
                    eventPrefix: "test_ev_",
                    userPropertyPrefix: "test_up_"
                ),
                manuallyTrackedEventsPrefixConfig: TAAnalyticsConfig.PrefixConfig(
                    eventPrefix: "manual_test_ev_",
                    userPropertyPrefix: "manual_test_up_"
                )
            )
        )
        await analytics.start()
    }
    
    @Test
    func testManualUserPropertiesArePrefixedCorrectly() {
        let up = UserPropertyAnalyticsModel("ta_test")
        
        analytics.set(userProperty: up, to: "123")
        
        // below can fail if setting & getting aren't both prefixed
        #expect(analytics.get(userProperty: up) == "123")
        
        #expect(analytics.stringFromUserDefaults(forKey: "userProperty_manual_test_up_ta_test") == "123")
    }

    @Test
    func testInternalUserPropertiesArePrefixedCorrectly() {
        analytics.set(userProperty: .APP_OPEN_COUNT, to: "123")
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == "123")
        
        #expect(analytics.stringFromUserDefaults(forKey: "userProperty_test_up_\(UserPropertyAnalyticsModel.APP_OPEN_COUNT.rawValue)") == "123")
    }

    @Test
    func testManualEventsArePrefixedCorrectly() async throws {
        let ev = EventAnalyticsModel("ta_test")
        
        analytics.track(event: ev)

        // TODO: fix this, because the events are now sent async via the buffer
        let _ = try await requireEvent(named: "manual_test_ev_ta_test")
    }

    @Test
    func testInternalEventsArePrefixedCorrectly() async throws {
        analytics.track(event: .APP_OPEN)

        // TODO: fix this, because the events are now sent async via the buffer
        let _ = try await requireEvent(named: "test_ev_\(EventAnalyticsModel.APP_OPEN.rawValue)")
    }
    
    func requireEvent(
        named eventName: String,
        matching predicate: @escaping (DeferredQueuedEvent) -> Bool = { _ in true },
        timeout: TimeInterval = 3
    ) async throws -> DeferredQueuedEvent {
        try await withThrowingTimeout(seconds: timeout) {
            for await deferredEvent in analytics.eventQueueBuffer.passthroughStream.stream {
                guard deferredEvent.event.rawValue == eventName else { continue }

                if predicate(deferredEvent) {
                    return deferredEvent
                }
            }

            Issue.record("No event found for \(eventName)")
            throw EventStreamError.eventNotFound
        }
    }
}
