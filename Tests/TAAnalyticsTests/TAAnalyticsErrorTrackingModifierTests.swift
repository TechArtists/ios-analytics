//
//  TAAnalyticsErrorTrackingModifierTests.swift
//  TAAnalyticsTests
//

import SwiftUI
import Testing
import UIKit
@testable import TAAnalytics

@MainActor
@Suite(.serialized)
struct TAAnalyticsErrorTrackingModifierTests {
    @Test
    func tracksOnlyWhenErrorPresentationBecomesActive() async throws {
        let (analytics, adaptor) = await makeAnalytics()
        let presentation = ErrorPresentationState()
        let window = makeWindow(analytics: analytics, presentation: presentation)
        defer { window.isHidden = true }

        #expect(errorEvents(in: adaptor).isEmpty)

        presentation.isPresented = true
        try await waitUntil { self.errorEvents(in: adaptor).count == 1 }

        let event = try #require(errorEvents(in: adaptor).first)
        #expect((event.params["reason"] as? String) == "PHOTO_LOAD_FAILED")
        #expect((event.params["source"] as? String) == "photo_library")

        presentation.isPresented = true
        await Task.yield()
        #expect(errorEvents(in: adaptor).count == 1)

        presentation.isPresented = false
        await Task.yield()
        presentation.isPresented = true
        try await waitUntil { self.errorEvents(in: adaptor).count == 2 }
    }

    @Test
    func doesNotTrackAnInitiallyPresentedError() async throws {
        let (analytics, adaptor) = await makeAnalytics()
        let presentation = ErrorPresentationState(isPresented: true)
        let window = makeWindow(analytics: analytics, presentation: presentation)
        defer { window.isHidden = true }

        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(errorEvents(in: adaptor).isEmpty)
    }

    private func makeWindow(
        analytics: TAAnalytics,
        presentation: ErrorPresentationState
    ) -> UIWindow {
        let view = ErrorTrackingTestView(
            analytics: analytics,
            presentation: presentation
        )
        let controller = UIHostingController(rootView: view)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        return window
    }

    private func makeAnalytics() async -> (TAAnalytics, TAAnalyticsUnitTestAdaptor) {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let adaptor = TAAnalyticsUnitTestAdaptor()
        let analytics = TAAnalytics(
            config: TAAnalyticsConfig(
                analyticsVersion: "1",
                adaptors: [adaptor],
                userDefaults: defaults
            )
        )
        await analytics.start()
        return (analytics, adaptor)
    }

    private func errorEvents(
        in adaptor: TAAnalyticsUnitTestAdaptor
    ) -> [(event: EventAnalyticsModelTrimmed, params: [String: (any AnalyticsBaseParameterValue)?])] {
        adaptor.eventsSent.filter { $0.event.rawValue == EventAnalyticsModel.ERROR.rawValue }
    }

    private func waitUntil(
        timeout: TimeInterval = 1,
        _ predicate: @escaping () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !predicate() {
            guard Date() < deadline else {
                Issue.record("Timed out waiting for the error analytics event")
                return
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}

@MainActor
private final class ErrorPresentationState: ObservableObject {
    @Published var isPresented: Bool

    init(isPresented: Bool = false) {
        self.isPresented = isPresented
    }
}

private struct ErrorTrackingTestView: View {
    let analytics: TAAnalytics
    @ObservedObject var presentation: ErrorPresentationState

    var body: some View {
        Color.clear.trackAnalyticsError(
            isPresented: presentation.isPresented,
            reason: "PHOTO_LOAD_FAILED",
            extraParams: ["source": "photo_library"]
        )
        .environmentObject(analytics)
    }
}
