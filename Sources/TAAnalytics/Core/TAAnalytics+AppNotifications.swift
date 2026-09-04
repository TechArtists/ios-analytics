//  TAAnalytics+AppNotifications.swift
//  Created by Adi on 11/17/22
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

import Foundation
import UIKit

public protocol TAAnalyticsAppNotificationsProtocol {
    /// Adds observers for app lifecycle events to log analytics and update user properties.
    /// Call during app setup to track lifecycle transitions.
    func addAppLifecycleObservers()
}

extension TAAnalytics: TAAnalyticsAppNotificationsProtocol {
    
    /// - Observers:
    ///   - **Foreground**: Logs the deferred cold `.APP_OPEN` after a background launch, or a warm `.APP_OPEN` after the initial open.
    ///   - **Background**: Logs `.APP_CLOSE`.
    public func addAppLifecycleObservers() {
        guard notificationCenterObservers.isEmpty else { return }

        let obsForeground = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            guard let self else { return }
            if self.hasTrackedInitialAppOpen {
                self.trackAppOpen(isColdLaunch: false)
            } else {
                self.trackInitialAppOpenIfNeeded()
            }
        }
        let obsBackground = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            guard let self else { return }
            var params = [String: (any AnalyticsBaseParameterValue)]()

            if let view = self.lastViewShow {
                self.addParameters(for: view, to: &params, prefix: "view_")
            }

            track(event: .APP_CLOSE, params: params)
        }

        notificationCenterObservers.append(obsForeground)
        notificationCenterObservers.append(obsBackground)
    }

    internal func trackInitialAppOpenIfNeeded() {
        guard config.currentProcessType == .app, !hasTrackedInitialAppOpen else { return }
        hasTrackedInitialAppOpen = true
        trackAppOpen(isColdLaunch: true)
    }

    /// Tracks the initial open immediately for a visible launch. A process started
    /// in the background defers this event until `willEnterForeground` fires.
    internal func trackInitialAppOpenIfForeground(applicationState: UIApplication.State? = nil) {
        guard config.currentProcessType == .app else { return }

        let currentApplicationState = applicationState ?? UIApplication.shared.applicationState
        guard currentApplicationState != .background else { return }

        trackInitialAppOpenIfNeeded()
    }

    internal func trackAppOpen(isColdLaunch: Bool) {
        set(userProperty: .APP_OPEN_COUNT, to: "\(getNextCounterValueFrom(userProperty: .APP_OPEN_COUNT))")

        var params: [String: (any AnalyticsBaseParameterValue)] = ["is_cold_launch": isColdLaunch]

        if let view = lastViewShow {
            addParameters(for: view, to: &params, prefix: "view_")
        }
        track(event: .APP_OPEN, params: params)
    }
}
