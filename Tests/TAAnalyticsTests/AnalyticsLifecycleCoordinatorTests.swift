//
//  AnalyticsLifecycleCoordinatorTests.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 08.09.2026.
//  Copyright (c) 2026 Tech Artists Agency SRL
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

import XCTest
import UIKit
@testable import TAAnalytics

final class AnalyticsLifecycleCoordinatorTests: XCTestCase {

    @MainActor func testLaunchReachesEveryObserverExactlyOnce() {
        let coordinator = AnalyticsLifecycleCoordinator(notificationCenter: NotificationCenter())
        let adaptor = LifecycleAdaptor()
        coordinator.launch(adaptors: [adaptor], application: .shared, launchOptions: nil)
        coordinator.launch(adaptors: [adaptor], application: .shared, launchOptions: nil)
        XCTAssertEqual(adaptor.launches, 1)
    }

    @MainActor func testLaunchOptionsAreHandedThrough() {
        let coordinator = AnalyticsLifecycleCoordinator(notificationCenter: NotificationCenter())
        let adaptor = LifecycleAdaptor()
        let url = URL(string: "https://example.com/onelink")!
        coordinator.launch(adaptors: [adaptor], application: .shared, launchOptions: [.url: url])
        XCTAssertEqual(adaptor.launchOptionsURL, url)
    }

    @MainActor func testAppStateEventsReachOnlyAdaptorsThatFinishedStartFor() {
        let center = NotificationCenter()
        let coordinator = AnalyticsLifecycleCoordinator(notificationCenter: center)
        let adaptor = LifecycleAdaptor()
        coordinator.launch(adaptors: [adaptor], application: .shared, launchOptions: nil)

        // startFor has not finished, so an SDK session must not be counted yet.
        center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        XCTAssertEqual(adaptor.events, [])

        coordinator.markReady(adaptor)
        center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        center.post(name: UIApplication.willResignActiveNotification, object: nil)
        center.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        XCTAssertEqual(adaptor.events,
                       ["didBecomeActive", "willResignActive", "didEnterBackground", "willEnterForeground"])
    }

    @MainActor func testEveryActivationIsForwarded() {
        let center = NotificationCenter()
        let coordinator = AnalyticsLifecycleCoordinator(notificationCenter: center)
        let adaptor = LifecycleAdaptor()
        coordinator.launch(adaptors: [adaptor], application: .shared, launchOptions: nil)
        coordinator.markReady(adaptor)
        // An inactive round trip — a system alert such as ATT — activates again without ever
        // backgrounding, and each activation is a session for SDKs that count them.
        for _ in 0..<3 {
            center.post(name: UIApplication.willResignActiveNotification, object: nil)
            center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        XCTAssertEqual(adaptor.events.filter { $0 == "didBecomeActive" }.count, 3)
    }

    @MainActor func testLinksReachObserversBeforePreparationFinishes() {
        let coordinator = AnalyticsLifecycleCoordinator(notificationCenter: NotificationCenter())
        let adaptor = LifecycleAdaptor()
        coordinator.launch(adaptors: [adaptor], application: .shared, launchOptions: nil)

        // A cold launch through a deep link arrives before startFor could have finished. Gating
        // links on readiness would drop the attribution the link exists to carry.
        let url = URL(string: "https://example.com/campaign")!
        coordinator.openURL(url, options: [:])
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        coordinator.continueUserActivity(activity)

        XCTAssertEqual(adaptor.openedURL, url)
        XCTAssertTrue(adaptor.continuedActivity === activity)
    }

    @MainActor func testMarkReadyIgnoresAdaptorsThatDoNotObserveTheLifecycle() {
        let center = NotificationCenter()
        let coordinator = AnalyticsLifecycleCoordinator(notificationCenter: center)
        let plain = TAAnalyticsUnitTestAdaptor()
        let observing = LifecycleAdaptor()
        coordinator.launch(adaptors: [plain, observing], application: .shared, launchOptions: nil)
        coordinator.markReady(plain)
        coordinator.markReady(observing)
        coordinator.markReady(observing)
        center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        // Registered once despite the repeated markReady, and the plain adaptor is simply skipped.
        XCTAssertEqual(observing.events, ["didBecomeActive"])
    }

    @MainActor func testAnAdaptorNeverMarkedReadyNeverSeesAppState() {
        let center = NotificationCenter()
        let coordinator = AnalyticsLifecycleCoordinator(notificationCenter: center)
        let adaptor = LifecycleAdaptor()
        coordinator.launch(adaptors: [adaptor], application: .shared, launchOptions: nil)
        for name: Notification.Name in [UIApplication.didBecomeActiveNotification,
                                        UIApplication.willResignActiveNotification,
                                        UIApplication.didEnterBackgroundNotification,
                                        UIApplication.willEnterForegroundNotification] {
            center.post(name: name, object: nil)
        }
        XCTAssertEqual(adaptor.events, [])
        XCTAssertEqual(adaptor.launches, 1)
    }
}

private final class LifecycleAdaptor: TAAnalyticsUnitTestAdaptor, AnalyticsAdaptorObservingAppLifecycle {
    @MainActor var launches = 0
    @MainActor var launchOptionsURL: URL?
    @MainActor var events: [String] = []
    @MainActor var openedURL: URL?
    @MainActor var continuedActivity: NSUserActivity?

    @MainActor func application(_ application: UIApplication,
                                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        launches += 1
        launchOptionsURL = launchOptions?[.url] as? URL
    }
    @MainActor func applicationDidBecomeActive() { events.append("didBecomeActive") }
    @MainActor func applicationWillResignActive() { events.append("willResignActive") }
    @MainActor func applicationDidEnterBackground() { events.append("didEnterBackground") }
    @MainActor func applicationWillEnterForeground() { events.append("willEnterForeground") }
    @MainActor func observeOpenURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) { openedURL = url }
    @MainActor func observeUserActivity(_ userActivity: NSUserActivity) { continuedActivity = userActivity }
}
