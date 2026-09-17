//
//  TAAnalyticsEngagementTests.swift
//  TAAnalyticsTests
//

import Foundation
import Testing
@testable import TAAnalytics

private extension EventAnalyticsModel {
    static let TEST_MATCH_COLOR = EventAnalyticsModel("match_color")
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

    // Deliberately covers the deprecated `String` overload, which stays supported
    // until it is removed in the next major version. The attribute keeps that
    // intent explicit instead of leaving a stray deprecation warning in the suite.
    @Test
    @available(*, deprecated, message: "Covers the deprecated String overload")
    func engagementMergesExtraParamsAfterViewContext() async throws {
        analytics.lastViewShow = ViewAnalyticsModel(name: "CAMERA", type: "LIVE_SCAN")

        analytics.track(
            engagement: "match_color",
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

    @Test
    func explicitViewOverridesAStaleLastViewShow() async throws {
        // Camera -> Paint Detail -> back. `.firstAppearance` tracking emits no
        // second `ui_view_show` for Camera, so `lastViewShow` is still Paint Detail.
        analytics.track(viewShow: ViewAnalyticsModel(name: "CAMERA", type: "LIVE_SCAN"))
        analytics.track(viewShow: ViewAnalyticsModel(name: "PAINT_DETAIL", type: "DETAIL"))

        analytics.track(
            engagementPrimary: .TEST_MATCH_COLOR,
            onView: ViewAnalyticsModel(name: "CAMERA", type: "LIVE_SCAN"),
            extraParams: ["id": "paint-123"]
        )

        try await waitUntil {
            self.events(named: EventAnalyticsModel.ENGAGEMENT_PRIMARY.rawValue).count == 1
        }

        for event in events(named: EventAnalyticsModel.ENGAGEMENT.rawValue)
            + events(named: EventAnalyticsModel.ENGAGEMENT_PRIMARY.rawValue) {
            #expect((event.params["view_name"] as? String) == "CAMERA")
            #expect((event.params["view_type"] as? String) == "LIVE_SCAN")
            #expect((event.params["id"] as? String) == "paint-123")
        }
        #expect(analytics.lastViewShow?.name == "PAINT_DETAIL")
    }

    @Test
    func explicitViewIsMergedForNonPrimaryEngagementToo() async throws {
        analytics.lastViewShow = ViewAnalyticsModel(name: "PAINT_DETAIL", type: "DETAIL")

        analytics.track(
            engagement: .TEST_MATCH_COLOR,
            onView: ViewAnalyticsModel(name: "COLOR_DETAIL", type: "DETAIL")
        )

        let event = try await requireEvent(named: EventAnalyticsModel.ENGAGEMENT.rawValue)
        #expect((event.params["view_name"] as? String) == "COLOR_DETAIL")
        #expect(events(named: EventAnalyticsModel.ENGAGEMENT_PRIMARY.rawValue).isEmpty)
    }

    @Test
    func explicitSecondaryViewKeepsItsParentViewContext() async throws {
        analytics.lastViewShow = ViewAnalyticsModel(name: "PAINT_DETAIL", type: "DETAIL")

        analytics.track(
            engagementPrimary: .TEST_MATCH_COLOR,
            onView: SecondaryViewAnalyticsModel(
                name: "PALETTE_PICKER",
                type: "SHEET",
                mainView: ViewAnalyticsModel(name: "CAMERA", type: "LIVE_SCAN")
            )
        )

        let event = try await requireEvent(named: EventAnalyticsModel.ENGAGEMENT_PRIMARY.rawValue)
        #expect((event.params["secondary_view_name"] as? String) == "PALETTE_PICKER")
        #expect((event.params["secondary_view_type"] as? String) == "SHEET")
        #expect((event.params["view_name"] as? String) == "CAMERA")
    }

    @Test
    func omittingTheViewStillFallsBackToLastViewShow() async throws {
        analytics.lastViewShow = ViewAnalyticsModel(name: "PAINT_DETAIL", type: "DETAIL")

        analytics.track(engagement: .TEST_MATCH_COLOR)

        let event = try await requireEvent(named: EventAnalyticsModel.ENGAGEMENT.rawValue)
        #expect((event.params["view_name"] as? String) == "PAINT_DETAIL")
    }

    @Test
    func mockConformsToAnalyticsProtocolAndCapturesPrimaryEngagement() {
        let mock = MockTAAnalytics()
        let analytics: any TAAnalyticsProtocol = mock
        mock.lastViewShow = ViewAnalyticsModel(name: "CAMERA", type: "LIVE_SCAN")

        analytics.track(
            engagementPrimary: .TEST_MATCH_COLOR,
            extraParams: [
                "id": "paint-123",
                "role": "CLOSEST_MATCH",
                "view_type": "CAPTURED_PHOTO"
            ]
        )

        #expect(mock.eventsSent.count == 2)
        #expect(mock.eventsSent[0].event == .ENGAGEMENT)
        #expect(mock.eventsSent[1].event == .ENGAGEMENT_PRIMARY)
        #expect((mock.eventsSent[0].params["name"] as? String) == EventAnalyticsModel.TEST_MATCH_COLOR.rawValue)
        #expect((mock.eventsSent[0].params["id"] as? String) == "paint-123")
        #expect((mock.eventsSent[0].params["role"] as? String) == "CLOSEST_MATCH")
        #expect((mock.eventsSent[0].params["view_name"] as? String) == "CAMERA")
        #expect((mock.eventsSent[0].params["view_type"] as? String) == "CAPTURED_PHOTO")
        #expect((mock.eventsSent[1].params["name"] as? String) == EventAnalyticsModel.TEST_MATCH_COLOR.rawValue)
        #expect((mock.eventsSent[1].params["id"] as? String) == "paint-123")
        #expect((mock.eventsSent[1].params["role"] as? String) == "CLOSEST_MATCH")
        #expect((mock.eventsSent[1].params["view_name"] as? String) == "CAMERA")
        #expect((mock.eventsSent[1].params["view_type"] as? String) == "CAPTURED_PHOTO")
    }

    @Test
    func mockCapturesTheExplicitViewThroughTheProtocol() {
        let mock = MockTAAnalytics()
        let analytics: any TAAnalyticsProtocol = mock
        mock.lastViewShow = ViewAnalyticsModel(name: "PAINT_DETAIL", type: "DETAIL")

        analytics.track(
            engagementPrimary: .TEST_MATCH_COLOR,
            onView: ViewAnalyticsModel(name: "CAMERA", type: "LIVE_SCAN"),
            extraParams: ["id": "paint-123"]
        )

        #expect(mock.eventsSent.count == 2)
        for event in mock.eventsSent {
            #expect((event.params["view_name"] as? String) == "CAMERA")
            #expect((event.params["view_type"] as? String) == "LIVE_SCAN")
            #expect((event.params["id"] as? String) == "paint-123")
        }
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
