//
//  TAAnalyticsSubscriptionTests.swift
//  TAAnalyticsTests
//

import Foundation
import Testing
@testable import TAAnalytics

@Suite(.serialized)
final class TAAnalyticsSubscriptionTests {
    let analytics: TAAnalytics
    let adaptor: TAAnalyticsUnitTestAdaptor

    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TAAnalyticsSubscriptionTests")
        let defaults = UserDefaults(suiteName: "TAAnalyticsSubscriptionTests")!
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
    func restoreCanBeTrackedWithoutUnavailableStoreMetadata() async throws {
        let paywall = TAPaywallAnalyticsImpl(
            analyticsPlacement: "SETTINGS",
            anayticsID: "paywall-id",
            analyticsName: "Settings Paywall"
        )

        analytics.trackSubscriptionRestore(
            TASubscriptionRestoreAnalyticsImpl(
                paywall: paywall,
                productID: "premium.yearly"
            )
        )

        let event = try await requireRestoreEvent()
        #expect((event.params["placement"] as? String) == "SETTINGS")
        #expect((event.params["product_id"] as? String) == "premium.yearly")
        #expect((event.params["quantity"] as? Int) == 1)
        #expect(event.params["price"] == nil)
        #expect(event.params["value"] == nil)
        #expect(event.params["currency"] == nil)
    }

    private func requireRestoreEvent() async throws -> (event: EventAnalyticsModelTrimmed, params: [String: (any AnalyticsBaseParameterValue)?]) {
        try await withThrowingTimeout(seconds: 3) {
            while true {
                if let event = self.adaptor.eventsSent.first(where: {
                    $0.event.rawValue == EventAnalyticsModel.SUBSCRIPTION_RESTORE.rawValue
                }) {
                    return event
                }

                try await Task.sleep(nanoseconds: 10_000_000)
            }
        }
    }
}
