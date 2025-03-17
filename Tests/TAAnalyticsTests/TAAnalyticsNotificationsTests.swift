//
//  TAAnalyticsNotificationsTests.swift
//  TAAnalytics
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
import UIKit

class TAAnalyticsNotificationsTests {

    var analytics: TAAnalytics
    let unitTestConsumer : TAAnalyticsUnitTestConsumer
    var notificationCenter = NotificationCenter.default
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATestsNotifcations")
        let defaults = UserDefaults(suiteName: "TATestsNotifcations")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer()
        analytics =  TAAnalytics(
            config: .init(analyticsVersion: "0", consumers: [unitTestConsumer], userDefaults: defaults)
        )
        await analytics.start()
    }
    
    @Test
    func testAddAppLifecycleObservers_ForegroundNotification() async throws {
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        let _ = try await requireEvent(named: "ta_APP_OPEN")
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == "1")
        
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        let _ = try await requireEvent(named: "ta_APP_OPEN")
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == "2")
    }
    
    @Test
    func testAddAppLifecycleObservers_BackgroundNotification() async throws {
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        let _ = try await requireEvent(named: "ta_app_background")
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
