//
//  TAAnalyticsNotificationsTests.swift
//  TAAnalytics
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

import Testing
import Foundation
import TAAnalytics
import UIKit

class TAAnalyticsNotificationsTests {

    var analytics = TAAnalytics(config: .init(analyticsVersion: "0", consumers: []))
    var notificationCenter = NotificationCenter.default
    
    @Test
    func testAddAppLifecycleObservers_ForegroundNotification() {
        // Arrange: Initialize the analytics object and call the addAppLifecycleObservers method
        analytics.addAppLifecycleObservers()
        
        // Act: Post the foreground notification
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Assert: Verify that isFirstForeground is toggled and the foreground ID was not incremented
        
        #expect(!analytics.isFirstForeground, "First foreground flag should be set to false after the first notification.")
        
        // Post the foreground notification again to check counter increment
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Assert: Verify that the foreground ID counter is incremented on the second foreground event
        
        #expect(analytics.get(userProperty: .FOREGROUND_COUNT) != "0", "Foreground ID should be incremented after the second notification.")
    }
}
