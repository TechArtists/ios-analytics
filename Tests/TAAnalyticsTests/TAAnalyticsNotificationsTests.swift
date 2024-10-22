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

    var analytics: TAAnalytics
    var notificationCenter = NotificationCenter.default
    
    init() {
        UserDefaults.standard.removePersistentDomain(forName: "TATests")
        let defaults = UserDefaults(suiteName: "TATests")!
        analytics =  TAAnalytics(config: .init(analyticsVersion: "0", consumers: [], userDefaults: defaults))
    }
    
    @Test
    func testAddAppLifecycleObservers_ForegroundNotification() {
        analytics.addAppLifecycleObservers()
        
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == "1")
        
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        #expect(analytics.get(userProperty: .APP_OPEN_COUNT) == "2")
    }
}
