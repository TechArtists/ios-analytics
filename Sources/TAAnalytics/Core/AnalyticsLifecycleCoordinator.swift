//
//  AnalyticsLifecycleCoordinator.swift
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

import UIKit

/// Forwards app lifecycle events to the adaptors that asked for them. It holds no policy of its
/// own: what each SDK does with an event is the adaptor's business.
///
/// Main-actor isolated so forwarding order is deterministic.
@MainActor
final class AnalyticsLifecycleCoordinator: NSObject {

    /// Adaptors that observe the app life cycle. Launch and link events go to all of them.
    private(set) var observers: [any AnalyticsAdaptorObservingAppLifecycle] = []

    /// Those whose `startFor` succeeded. The four app-state events go only to these, so an adaptor
    /// TAAnalytics excluded from event delivery does not keep counting sessions in its SDK.
    private var ready: [any AnalyticsAdaptorObservingAppLifecycle] = []

    private var didLaunch = false
    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        super.init()
    }

    func launch(adaptors: [any AnalyticsAdaptor], application: UIApplication,
                launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard !didLaunch else { return }
        didLaunch = true
        observers = adaptors.compactMap { $0 as? any AnalyticsAdaptorObservingAppLifecycle }

        let events: [(Notification.Name, Selector)] = [
            (UIApplication.didBecomeActiveNotification, #selector(didBecomeActive)),
            (UIApplication.willResignActiveNotification, #selector(willResignActive)),
            (UIApplication.didEnterBackgroundNotification, #selector(didEnterBackground)),
            (UIApplication.willEnterForegroundNotification, #selector(willEnterForeground))
        ]
        for (name, selector) in events {
            notificationCenter.addObserver(self, selector: selector, name: name, object: nil)
        }

        for observer in observers {
            observer.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    }

    /// Records that `startFor` succeeded, making the adaptor eligible for app-state events.
    func markReady(_ adaptor: any AnalyticsAdaptor) {
        guard let adaptor = adaptor as? any AnalyticsAdaptorObservingAppLifecycle,
              observers.contains(where: { $0 === adaptor }),
              !ready.contains(where: { $0 === adaptor }) else { return }
        ready.append(adaptor)
    }

    // A cold launch through a deep link arrives before preparation could have finished, so links
    // reach every observer rather than only the ready ones.
    func openURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {
        observers.forEach { $0.observeOpenURL(url, options: options) }
    }

    func continueUserActivity(_ userActivity: NSUserActivity) {
        observers.forEach { $0.observeUserActivity(userActivity) }
    }

    @objc func didBecomeActive() { ready.forEach { $0.applicationDidBecomeActive() } }
    @objc func willResignActive() { ready.forEach { $0.applicationWillResignActive() } }
    @objc func didEnterBackground() { ready.forEach { $0.applicationDidEnterBackground() } }
    @objc func willEnterForeground() { ready.forEach { $0.applicationWillEnterForeground() } }
}

public extension TAAnalytics {

    /// Call synchronously from `didFinishLaunchingWithOptions`, after SDK prerequisites, so that
    /// adaptors needing a usable SDK before that method returns get one. `start()` calls this too,
    /// as a fallback for hosts without app-delegate integration.
    /// `application` defaults to `UIApplication.shared`, resolved in the body rather than as a
    /// default argument: default arguments are evaluated outside the enclosing declaration's
    /// isolation, so `= .shared` reads main-actor state from a nonisolated context.
    @MainActor func applicationDidFinishLaunching(
        _ application: UIApplication? = nil,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) {
        if adaptorLifecycle == nil { adaptorLifecycle = AnalyticsLifecycleCoordinator() }
        adaptorLifecycle?.launch(adaptors: config.adaptors,
                                 application: application ?? .shared,
                                 launchOptions: launchOptions)
    }

    /// Observes links without claiming routing ownership.
    @MainActor func applicationOpen(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) {
        adaptorLifecycle?.openURL(url, options: options)
    }

    @MainActor func applicationContinue(_ userActivity: NSUserActivity) {
        adaptorLifecycle?.continueUserActivity(userActivity)
    }
}
