//
//  TAAnalyticsFilterEventsTests.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 17.01.2025.
//

import Testing
import Foundation
@testable import TAAnalytics

class TAAnalyticsFilterEventsTests {

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
