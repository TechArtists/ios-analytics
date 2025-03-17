//  TAAnalyticsTests.swift
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
import Testing
import Foundation
@testable import TAAnalytics

class TAAnalyticsTrimTests {
    let analytics: TAAnalytics
    let unitTestConsumer : TAAnalyticsUnitTestConsumer
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATests")
        let mockUserDefaults = UserDefaults(suiteName: "TATests")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer(eventTrimLength: 7, userPropertyTrimLength: 7)
        analytics =  TAAnalytics(
            config: .init(
                analyticsVersion: "0",
                consumers: [unitTestConsumer],
                userDefaults: mockUserDefaults
            )
        )
        await analytics.start()
    }
    
    @Test
    func testTrimmingEvents() async throws {
        let trimmedEvent = unitTestConsumer.trim(event: .init("ta_test_test_test"))
        unitTestConsumer.track(trimmedEvent: trimmedEvent, params: nil)
        
        #expect(unitTestConsumer.eventsSent.contains(where: { $0.event.rawValue == "ta_test" }))
    }

    @Test
    func testTrimmingUserProperties() {
        let trimmedUserProperty = unitTestConsumer.trim(userProperty: UserPropertyAnalyticsModel("ta_test_test_test"))
        unitTestConsumer.set(trimmedUserProperty: trimmedUserProperty, to: "")
        
        #expect(unitTestConsumer.userPropertiesSet.contains(where: { $0.key.rawValue == "ta_test" }))
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
