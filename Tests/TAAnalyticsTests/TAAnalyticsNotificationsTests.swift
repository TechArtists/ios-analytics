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

@Suite(.serialized)
final class TAAnalyticsNotificationsTests {

    var analytics: TAAnalytics
    let unitTestAdaptor : TAAnalyticsUnitTestAdaptor
    var notificationCenter = NotificationCenter.default
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATestsNotifcations")
        let defaults = UserDefaults(suiteName: "TATestsNotifcations")!
        unitTestAdaptor = TAAnalyticsUnitTestAdaptor()
        analytics =  TAAnalytics(
            config: .init(analyticsVersion: "0", adaptors: [unitTestAdaptor], userDefaults: defaults)
        )
        await analytics.start()
    }
    
    @Test
    func testStartTracksColdAppOpen() async throws {
        let coldOpen = try await requireAdaptorEvent(
            named: EventAnalyticsModel.APP_OPEN.rawValue,
            matching: { ($0.params["is_cold_launch"] as? Bool) == true }
        )

        #expect((coldOpen.params["is_cold_launch"] as? Bool) == true)
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == "1")
    }

    @Test
    func testAddAppLifecycleObservers_ForegroundNotification() async throws {
        _ = try await requireAdaptorEvent(named: EventAnalyticsModel.APP_OPEN.rawValue)

        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == "2")

        let warmOpen = try await requireAdaptorEvent(
            named: EventAnalyticsModel.APP_OPEN.rawValue,
            matching: { ($0.params["is_cold_launch"] as? Bool) == false }
        )
        #expect((warmOpen.params["is_cold_launch"] as? Bool) == false)
    }

    @Test
    func testBackgroundLaunchDefersColdOpenUntilForeground() async throws {
        unitTestAdaptor.eventsSent.removeAll()
        analytics.hasTrackedInitialAppOpen = false
        analytics.set(userProperty: .APP_OPEN_COUNT, to: nil)

        analytics.trackInitialAppOpenIfForeground(applicationState: .background)

        #expect(
            unitTestAdaptor.eventsSent.contains {
                $0.event.rawValue == EventAnalyticsModel.APP_OPEN.rawValue
            } == false
        )
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == nil)

        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        let coldOpen = try await requireAdaptorEvent(
            named: EventAnalyticsModel.APP_OPEN.rawValue,
            matching: { ($0.params["is_cold_launch"] as? Bool) == true }
        )
        #expect((coldOpen.params["is_cold_launch"] as? Bool) == true)
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == "1")
    }
    
    @Test
    func testAddAppLifecycleObservers_BackgroundNotification() async throws {
        let lastView = ViewAnalyticsModel(
            name: "CAMERA",
            type: "LIVE_SCAN",
            funnelStep: AnalyticsViewFunnelStepDetails(
                funnelName: "MATCH_COLOR",
                step: 2,
                isOptionalStep: false,
                isFinalStep: true
            )
        )
        analytics.track(viewShow: lastView)

        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        let appClose = try await requireAdaptorEvent(
            named: EventAnalyticsModel.APP_CLOSE.rawValue,
            matching: { ($0.params["view_name"] as? String) == lastView.name }
        )

        #expect((appClose.params["view_name"] as? String) == "CAMERA")
        #expect((appClose.params["view_type"] as? String) == "LIVE_SCAN")
        #expect((appClose.params["view_funnel_name"] as? String) == "MATCH_COLOR")
        #expect((appClose.params["view_funnel_step"] as? Int) == 2)
        #expect((appClose.params["view_funnel_step_is_optional"] as? Bool) == false)
        #expect((appClose.params["view_funnel_step_is_final"] as? Bool) == true)
        #expect(
            analytics.get(userProperty: .LAST_VIEW_SHOW) ==
            "name=CAMERA;type=LIVE_SCAN;funnel_name=MATCH_COLOR;funnel_step=2;funnel_step_is_optional=false;funnel_step_is_final=true"
        )
    }

    func requireAdaptorEvent(
        named eventName: String,
        matching predicate: @escaping ((event: EventAnalyticsModelTrimmed, params: [String: (any AnalyticsBaseParameterValue)?])) -> Bool = { _ in true },
        timeout: TimeInterval = 3
    ) async throws -> (event: EventAnalyticsModelTrimmed, params: [String: (any AnalyticsBaseParameterValue)?]) {
        try await withThrowingTimeout(seconds: timeout) {
            while true {
                if let event = self.unitTestAdaptor.eventsSent.first(where: {
                    $0.event.rawValue == eventName && predicate($0)
                }) {
                    return event
                }

                try await Task.sleep(nanoseconds: 10_000_000)
            }
        }
    }
}
