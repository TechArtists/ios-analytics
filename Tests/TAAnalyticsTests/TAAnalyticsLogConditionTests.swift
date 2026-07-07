//
//  TAAnalyticsLogConditionTests.swift
//  TAAnalytics
//
//  Created by OpenAI on 06.07.2026.
//

import Foundation
import Testing
@testable import TAAnalytics

class TAAnalyticsLogConditionTests {

    let analytics: TAAnalytics
    let unitTestAdaptor: TAAnalyticsUnitTestAdaptor
    let suiteName: String

    init() async {
        suiteName = "TAAnalyticsLogConditionTests"
        UserDefaults.standard.removePersistentDomain(forName: suiteName)

        let mockUserDefaults = UserDefaults(suiteName: suiteName)!
        unitTestAdaptor = TAAnalyticsUnitTestAdaptor()
        analytics = TAAnalytics(
            config: .init(
                analyticsVersion: "1",
                adaptors: [unitTestAdaptor],
                userDefaults: mockUserDefaults
            )
        )

        await analytics.start(shouldTrackFirstOpen: false)
    }

    deinit {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
    }

    @Test
    func logOnlyOncePerLifetimeLogsOnFirstAttempt() async throws {
        let event = EventAnalyticsModel("lifetime_event")

        analytics.track(event: event, logCondition: .logOnlyOncePerLifetime)

        try await waitForLoggedEventCount(named: event.rawValue, count: 1)

        #expect(loggedEventCount(named: event.rawValue) == 1)
        #expect(analytics.boolFromUserDefaults(forKey: "onlyOnce_\(event.rawValue)") == true)
    }

    @Test
    func firstOpenIsLoggedOnFirstStart() async throws {
        let suiteName = "TAAnalyticsLogConditionTests.firstOpen"
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        let mockUserDefaults = UserDefaults(suiteName: suiteName)!
        let adaptor = TAAnalyticsUnitTestAdaptor()
        let analytics = TAAnalytics(
            config: .init(
                analyticsVersion: "1",
                adaptors: [adaptor],
                userDefaults: mockUserDefaults
            )
        )

        await analytics.start()

        try await waitForLoggedEventCount(named: EventAnalyticsModel.OUR_FIRST_OPEN.rawValue, count: 1, adaptor: adaptor)

        let firstOpenCount = adaptor.eventsSent.filter {
            $0.event.rawValue == EventAnalyticsModel.OUR_FIRST_OPEN.rawValue
        }.count

        #expect(firstOpenCount == 1)
        #expect(analytics.boolFromUserDefaults(forKey: "onlyOnce_\(EventAnalyticsModel.OUR_FIRST_OPEN.rawValue)") == true)
    }

    @Test
    func filteredLifetimeEventIsNotMarkedAsLogged() async throws {
        final class FilterState: @unchecked Sendable {
            var shouldAllowEvent = false
        }

        let suiteName = "TAAnalyticsLogConditionTests.filteredLifetime"
        let filterState = FilterState()
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        let mockUserDefaults = UserDefaults(suiteName: suiteName)!
        let adaptor = TAAnalyticsUnitTestAdaptor()
        let analytics = TAAnalytics(
            config: .init(
                analyticsVersion: "1",
                adaptors: [adaptor],
                userDefaults: mockUserDefaults,
                trackEventFilter: { event, _ in
                    guard event.rawValue == "filtered_lifetime_event" else { return true }
                    return filterState.shouldAllowEvent
                }
            )
        )

        await analytics.start(shouldTrackFirstOpen: false)

        let event = EventAnalyticsModel("filtered_lifetime_event")
        analytics.track(event: event, logCondition: .logOnlyOncePerLifetime)

        try await Task.sleep(seconds: 0.05)

        #expect(adaptor.eventsSent.filter { $0.event.rawValue == event.rawValue }.isEmpty)
        #expect(analytics.boolFromUserDefaults(forKey: "onlyOnce_\(event.rawValue)") == nil)

        filterState.shouldAllowEvent = true
        analytics.track(event: event, logCondition: .logOnlyOncePerLifetime)

        try await waitForLoggedEventCount(named: event.rawValue, count: 1, adaptor: adaptor)

        #expect(adaptor.eventsSent.filter { $0.event.rawValue == event.rawValue }.count == 1)
        #expect(analytics.boolFromUserDefaults(forKey: "onlyOnce_\(event.rawValue)") == true)
    }

    private func loggedEventCount(named eventName: String, adaptor: TAAnalyticsUnitTestAdaptor? = nil) -> Int {
        let adaptor = adaptor ?? unitTestAdaptor
        return adaptor.eventsSent.filter { $0.event.rawValue == eventName }.count
    }

    private func waitForLoggedEventCount(
        named eventName: String,
        count expectedCount: Int,
        adaptor: TAAnalyticsUnitTestAdaptor? = nil,
        timeout: TimeInterval = 2
    ) async throws {
        try await withThrowingTimeout(seconds: timeout) {
            while self.loggedEventCount(named: eventName, adaptor: adaptor) < expectedCount {
                try await Task.sleep(seconds: 0.01)
            }
        }
    }
}
