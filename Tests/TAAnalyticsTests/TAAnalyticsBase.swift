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

enum EventStreamError: Error {
    case eventNotFound
}

class TAAnalyticsBase {
    let analytics: TAAnalytics
    let unitTestConsumer : TAAnalyticsUnitTestConsumer
    let notificationCenter = NotificationCenter.default
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATests")
        let mockUserDefaults = UserDefaults(suiteName: "TATests")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer()
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
    func testThatNilsAreNotSentToConsumers() async throws {

        var params = [String: (any AnalyticsBaseParameterValue)?]()
        params["key1"] = "value1"
        params["key2"] = nil
        params["key3"] = "value3"
        
        analytics.track(event: .OUR_FIRST_OPEN, params: params, logCondition: .logAlways)
        
        let deferredEvent = try await requireEvent(named: "our_first_open")
        #expect(deferredEvent.parameters?.count == 2)
        #expect((deferredEvent.parameters?["key1"] as! String) == "value1")
        #expect(deferredEvent.parameters?["key2"] == nil)
        #expect((deferredEvent.parameters?["key3"] as! String) == "value3")
    }
    
    func requireEvent(
        named eventName: String,
        matching predicate: @escaping (DeferredQueuedEvent) -> Bool = { _ in true },
        timeout: TimeInterval = 3
    ) async throws -> DeferredQueuedEvent {
        try await withThrowingTimeout(seconds: timeout) {
            for await eventSpecific in analytics.eventQueueBuffer.passthroughStream.stream {
                guard eventSpecific.event.rawValue == eventName else { continue }

                if predicate(eventSpecific) {
                    return eventSpecific
                }
            }

            Issue.record("No event found for \(eventName)")
            throw EventStreamError.eventNotFound
        }
    }
}
