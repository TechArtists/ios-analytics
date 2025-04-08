//
//  TAAnalyticsFilterEventsTests.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 17.01.2025.
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

import Testing
import Foundation
@testable import TAAnalytics

class TAAnalyticsFilterEventsTests {

    let analytics: TAAnalytics
    let unitTestAdaptor: TAAnalyticsUnitTestAdaptor
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATestsPrefix")
        let mockUserDefaults = UserDefaults(suiteName: "TATestsPrefix")!
        unitTestAdaptor = TAAnalyticsUnitTestAdaptor()
        analytics = TAAnalytics(
            config: TAAnalyticsConfig(
                analyticsVersion: "1",
                adaptors: [unitTestAdaptor],
                userDefaults: mockUserDefaults,
                trackEventFilter: { event, parameters in
                    if event.rawValue == "manual_test_filter_ta_test" {
                        return false
                    }
                    return true
                }
            )
        )
        await analytics.start()
    }
    
    deinit {
        UserDefaults.standard.removePersistentDomain(forName: "TATestsPrefix")
    }
    
    @Test
    func testFilterEventsClosure() async {
        let event = EventAnalyticsModel("manual_test_filter_ta_test")
        
        analytics.track(event: event)

        let expectedEvent = await expectEvent(named: "manual_test_ev_ta_test", timeout: 2)
        #expect(expectedEvent == nil)
    }
    
    func requireEvent(
        named eventName: String,
        matching predicate: @escaping (DeferredQueuedEvent) -> Bool = { _ in true },
        timeout: TimeInterval = 3
    ) async throws -> DeferredQueuedEvent {
        if let event = await expectEvent(named: eventName, matching: predicate, timeout: timeout) {
            return event
        } else {
            Issue.record("No event found for \(eventName)")
            throw EventStreamError.eventNotFound
        }
    }
    
    func expectEvent(
        named eventName: String,
        matching predicate: @escaping (DeferredQueuedEvent) -> Bool = { _ in true },
        timeout: TimeInterval = 3
    ) async -> DeferredQueuedEvent? {
        return try? await withThrowingTimeout(seconds: timeout) {
            for await deferredEvent in analytics.eventQueueBuffer.passthroughStream.stream {
                guard deferredEvent.event.rawValue == eventName else { continue }
                
                if predicate(deferredEvent) {
                    return deferredEvent
                }
            }
            return nil
        }
    }
}
