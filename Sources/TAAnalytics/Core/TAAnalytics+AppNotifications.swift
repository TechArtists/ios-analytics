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

extension TAAnalytics: TAAnalyticsAppNotificationsProtocol {
    
    /// - Observers:
    ///   - **Foreground**: Increments `FOREGROUND_ID` and logs `.APP_FOREGROUND` (skips increment on first event).
    ///   - **Background**: Logs `.APP_BACKGROUND`.
    public func addAppLifecycleObservers() {
        
        let obsForeground = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { notification in

            if self.isFirstForeground {
                // ignore increasing the counter for the first one,
                // because the foreground id has already been set to 0 as TAAnalytics was starting up
                self.isFirstForeground = false
            } else {
                self.set(userProperty: .FOREGROUND_ID,
                         to:"\(self.getNextCounterValueFrom(userProperty: .FOREGROUND_ID))")
            }
            
            self.track(event: .APP_FOREGROUND)
        }
        let obsBackground = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { notification in
            
            // add user property for last view types shown
            var params = [String: AnalyticsBaseParameterValue]()

            params["last_parent_view_name"] = self.lastParentViewShown?.name
            params["last_parent_view_type"] = self.lastParentViewShown?.type
            params["last_parent_view_group_name"] = self.lastParentViewShown?.groupDetails?.name
            params["last_parent_view_group_order"] = self.lastParentViewShown?.groupDetails?.order
            params["last_parent_view_group_stage"] = self.lastParentViewShown?.groupDetails?.stage.description

            self.track(event: .APP_BACKGROUND, params: params)
        }
        
        notificationCenterObservers.append(obsForeground)
        notificationCenterObservers.append(obsBackground)
    }
}
