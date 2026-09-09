//
//  AnalyticsAdaptorObservingAppLifecycle.swift
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

/// An adaptor whose SDK needs app lifecycle events. TAAnalytics forwards them; it prescribes no
/// sequence of its own, so an adaptor implements whichever combination its SDK needs and ignores
/// the rest. Every member is optional.
///
/// Delivery has one rule. Launch and link events reach every conforming adaptor, because a cold
/// launch through a deep link arrives before preparation could possibly have finished. The four
/// app-state events reach only adaptors whose `startFor` succeeded, so an adaptor that TAAnalytics
/// excluded from event delivery does not go on counting sessions in its SDK.
///
/// Every member is main-actor isolated; tracking stays off it.
public protocol AnalyticsAdaptorObservingAppLifecycle: AnyObject {

    /// The app finished launching. Configure the SDK here — credentials, flags, delegates — when
    /// it has to be usable before `didFinishLaunchingWithOptions` returns, which is what a deep
    /// link arriving on a cold launch requires. Anything that can wait belongs in `startFor`.
    ///
    /// Must not suspend. Cannot fail: an adaptor that cannot configure itself should record that
    /// and refuse in `startFor`, which is where TAAnalytics can still exclude it.
    @MainActor func application(_ application: UIApplication,
                                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)

    /// The app became active. This is activation, not foregrounding: a system alert such as ATT,
    /// an incoming call, or Notification Center takes the app merely inactive and posts this again
    /// on the way back, with no background transition in between.
    @MainActor func applicationDidBecomeActive()

    @MainActor func applicationWillResignActive()

    @MainActor func applicationDidEnterBackground()

    @MainActor func applicationWillEnterForeground()

    /// Observes an incoming URL before any app router sees it, so a claimed link still reaches the
    /// SDK. Observation only, routing is unaffected.
    @MainActor func observeOpenURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any])

    /// Observes a continued user activity, such as a Universal Link. Same contract as
    /// `observeOpenURL(_:options:)`.
    @MainActor func observeUserActivity(_ userActivity: NSUserActivity)
}

public extension AnalyticsAdaptorObservingAppLifecycle {
    @MainActor func application(_ application: UIApplication,
                                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {}
    @MainActor func applicationDidBecomeActive() {}
    @MainActor func applicationWillResignActive() {}
    @MainActor func applicationDidEnterBackground() {}
    @MainActor func applicationWillEnterForeground() {}
    @MainActor func observeOpenURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {}
    @MainActor func observeUserActivity(_ userActivity: NSUserActivity) {}
}
