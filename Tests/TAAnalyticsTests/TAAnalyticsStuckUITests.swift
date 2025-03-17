//
//  TAAnalyticsUITests.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 16.01.2025.
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

class TAAnalyticsUITests {
    let analytics: TAAnalytics
    let testView = ViewAnalyticsModel(name: "TestView", type: "TestType")
    let unitTestConsumer: TAAnalyticsUnitTestConsumer
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATests")
        let mockUserDefaults = UserDefaults(suiteName: "TATests")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer(eventTrimLength: 40, userPropertyTrimLength: 100)
        analytics = TAAnalytics(
            config: .init(
                analyticsVersion: "0",
                consumers: [unitTestConsumer],
                userDefaults: mockUserDefaults
            )
        )
        await analytics.start()
    }
    
    @Test("Stuck event triggered after timer")
    func testStuckEventTriggeredAfterTimer() async throws {
        analytics.track(viewShow: testView, stuckTimer: 2)
        
        let deferredQueuedEvent = try await requireEvent(named: "error_stuck_on_ui_view_show", timeout: 5)
        
        #expect(deferredQueuedEvent.parameters?["name"] as? String == testView.name)
    }
    
    @Test("Stuck timer canceled by new view")
    func testStuckTimerCanceledByNewView() async throws {
        analytics.track(viewShow: testView, stuckTimer: 5)
        let newView = ViewAnalyticsModel(name: "NewView", type: nil)
        analytics.track(viewShow: newView)
        
        let event = await expectEvent(named: "error_stuck_on_ui_view_show", timeout: 6)
        #expect(event == nil || (event?.parameters?["name"] as? String != testView.name))
    }
    
    @Test("Corrected error event after stuck")
    func testCorrectedErrorEventAfterStuck() async throws {
        analytics.track(viewShow: testView, stuckTimer: 2)
        
        _ = try await requireEvent(named: "error_stuck_on_ui_view_show")
        
        // Show a new view after the stuck error
        let newView = ViewAnalyticsModel(name: "NewView", type: nil)
        analytics.track(viewShow: newView)
        
        let correctedEvent = try await requireEvent(named: "corrected_error_stuck_on_ui_view_show", timeout: 5)
        
        #expect(correctedEvent.parameters?["name"] as? String == testView.name)
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
