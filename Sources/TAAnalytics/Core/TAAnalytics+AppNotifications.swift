//  File.swift
//  Created by Adi on 11/17/22
//
//  Copyright (c) 2022 Tech Artists Agency SRL (http://TA.com/)
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

// TODO: move it into TAAnlytics
var isFirstAppOpenThisProcess = false

extension TAAnalytics: TAAnalyticsAppNotificationsProtocol {
    
    /// - Observers:
    ///   - **Foreground**: Increments `FOREGROUND_COUNT` and logs `.APP_FOREGROUND` (skips increment on first event).
    ///   - **Background**: Logs `.APP_BACKGROUND`.
    public func addAppLifecycleObservers() {
        
        let obsForeground = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { notification in

            // TODO: adi user defaults guard for is ready?
            self.set(userProperty: .APP_OPEN_COUNT,
                     to:"\(self.getNextCounterValueFrom(userProperty: .APP_OPEN_COUNT))")
            
            if isFirstAppOpenThisProcess {
                self.track(event: .APP_OPEN, params: ["is_cold_launch": true])
                isFirstAppOpenThisProcess = true
            } else {
                self.track(event: .APP_OPEN, params: ["is_cold_launch": false])
            }
        }
        let obsBackground = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { notification in
            
            // TODO: add unit test for last view shown
            // add user property for last view types shown
            var params = [String: AnalyticsBaseParameterValue]()

            params["last_parent_view_name"] = self.lastParentViewShown?.name
            params["last_parent_view_type"] = self.lastParentViewShown?.type
            params["last_parent_view_group_name"] = self.lastParentViewShown?.groupDetails?.name
            params["last_parent_view_group_order"] = self.lastParentViewShown?.groupDetails?.order
            params["last_parent_view_group_stage"] = self.lastParentViewShown?.groupDetails?.stage.description

            self.track(event: .APP_CLOSE, params: params)
        }
        
        notificationCenterObservers.append(obsForeground)
        notificationCenterObservers.append(obsBackground)
    }
}
