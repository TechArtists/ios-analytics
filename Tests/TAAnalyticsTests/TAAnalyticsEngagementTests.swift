//
//  TAAnalyticsEngagementTests.swift
//  TAAnalyticsTests
//

import Foundation
import Testing
@testable import TAAnalytics

private extension EventAnalyticsModel {
    static let TEST_MATCH_COLOR = EventAnalyticsModel("MATCH_COLOR")
}

@Suite(.serialized)
final class TAAnalyticsEngagementTests {
    let analytics: TAAnalytics
    let adaptor: TAAnalyticsUnitTestAdaptor

    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TAAnalyticsEngagementTests")
        let defaults = UserDefaults(suiteName: "TAAnalyticsEngagementTests")!
        adaptor = TAAnalyticsUnitTestAdaptor()
        analytics = TAAnalytics(
            config: .init(
                analyticsVersion: "2.0",
                adaptors: [adaptor],
                userDefaults: defaults
            )
        )
        await analytics.start()
    }

    @Test
    func typedEngagementUsesTheCentralizedIdentifierAndViewContext() async throws {
        analytics.lastViewShow = ViewAnalyticsModel(name: "CAMERA", type: "LIVE_SCAN")

        analytics.track(engagement: .TEST_MATCH_COLOR)

        let event = try await requireEvent(named: EventAnalyticsModel.ENGAGEMENT.rawValue)
        #expect((event.params["name"] as? String) == EventAnalyticsModel.TEST_MATCH_COLOR.rawValue)
        #expect((event.params["view_name"] as? String) == "CAMERA")
        #expect((event.params["view_type"] as? String) == "LIVE_SCAN")
    }

    @Test
    func engagementMergesExtraParamsAfterViewContext() async throws {
        analytics.lastViewShow = ViewAnalyticsModel(name: "CAMERA", type: "LIVE_SCAN")

        analytics.track(
            engagement: "MATCH_COLOR",
            extraParams: [
                "id": "paint-123",
                "role": "closest_match",
                "view_type": "CAPTURED_PHOTO"
            ]
        )

        let event = try await requireEvent(named: EventAnalyticsModel.ENGAGEMENT.rawValue)
        #expect((event.params["id"] as? String) == "paint-123")
        #expect((event.params["role"] as? String) == "closest_match")
        #expect((event.params["view_name"] as? String) == "CAMERA")
        #expect((event.params["view_type"] as? String) == "CAPTURED_PHOTO")
    }

    @Test
    func typedPrimaryEngagementEmitsThePrimaryAndCompanionEventsOnce() async throws {
        analytics.track(
            engagementPrimary: .TEST_MATCH_COLOR,
            extraParams: [
                "id": "paint-123",
                "role": "primary_match"
            ]
        )

        try await waitUntil {
            self.events(named: EventAnalyticsModel.ENGAGEMENT.rawValue).count == 1 &&
            self.events(named: EventAnalyticsModel.ENGAGEMENT_PRIMARY.rawValue).count == 1
        }

        let companion = events(named: EventAnalyticsModel.ENGAGEMENT.rawValue).first
        let primary = events(named: EventAnalyticsModel.ENGAGEMENT_PRIMARY.rawValue).first
        #expect((companion?.params["name"] as? String) == EventAnalyticsModel.TEST_MATCH_COLOR.rawValue)
        #expect((primary?.params["name"] as? String) == EventAnalyticsModel.TEST_MATCH_COLOR.rawValue)
        #expect((companion?.params["id"] as? String) == "paint-123")
        #expect((companion?.params["role"] as? String) == "primary_match")
        #expect((primary?.params["id"] as? String) == "paint-123")
        #expect((primary?.params["role"] as? String) == "primary_match")
    }

    private func events(named name: String) -> [(event: EventAnalyticsModelTrimmed, params: [String: (any AnalyticsBaseParameterValue)?])] {
        adaptor.eventsSent.filter { $0.event.rawValue == name }
    }

    private func requireEvent(
        named name: String
    ) async throws -> (event: EventAnalyticsModelTrimmed, params: [String: (any AnalyticsBaseParameterValue)?]) {
        try await waitUntil {
            !self.events(named: name).isEmpty
        }
        return events(named: name)[0]
    }

    private func waitUntil(
        timeout: TimeInterval = 3,
        _ predicate: @escaping () -> Bool
    ) async throws {
        try await withThrowingTimeout(seconds: timeout) {
            while !predicate() {
                try await Task.sleep(nanoseconds: 10_000_000)
            }
        }
    }
}
