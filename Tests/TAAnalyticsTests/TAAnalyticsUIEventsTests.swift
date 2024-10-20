//  TAAnalyticsTests.swift
//  Created by Adi on 10/24/22
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
import UIKit
import TAAnalytics

class TAAnalyticsUIEventsTests {
    
    let analytics: TAAnalytics
    let unitTestConsumer : TAAnalyticsUnitTestConsumer
    let notificationCenter = NotificationCenter.default
    
    init() {
        UserDefaults.standard.removePersistentDomain(forName: "TATests")
        let mockUserDefaults = UserDefaults(suiteName: "TATests")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer()
        let ta = TAAnalytics(config: TAAnalyticsConfig(analyticsVersion: "1", consumers: [unitTestConsumer],userDefaults: mockUserDefaults))

        analytics =  TAAnalytics(config: .init(analyticsVersion: "0", consumers: [], userDefaults: mockUserDefaults))
    }
        
    @Test
    func testLastViewShownOnlyRemembersParentViews() {
        analytics.addAppLifecycleObservers()

        let step1 = AnalyticsView(name: "step 1", type: nil, groupDetails: AnalyticsViewGroupDetails(name: "onboarding", order: 1, isFinalScreen: false))
        let step1Subview = AnalyticsView(name: "incorrect email label", type: "foo", parentView: step1)
        let step2 = AnalyticsView(name: "step 2", type: nil, groupDetails: AnalyticsViewGroupDetails(name: "onboarding", order: 2, isFinalScreen: false))
        let step3 = AnalyticsView(name: "step 3", type: nil, groupDetails: AnalyticsViewGroupDetails(name: "onboarding", order: 3, isFinalScreen: true))

        
        analytics.track(viewShown: step1)
        analytics.track(viewShown: step1Subview)
        // TODO: test that sending the step1 subview does not have any "group_" parameters on it
        // (impossible due to the separate the swift initializers, but we should test it in case someone refactors the initializers in the future)
        // . Only the "parent_view" parameters populated
        
        // it should only keep track of parent views, not subviews
        #expect(analytics.lastParentViewShown == step1)
        #expect(analytics.get(userProperty: .LAST_PARENT_VIEW_SHOWN) == "step 1;nil;onboarding;1;start")
        
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // TODO: verify the parameters on the .app_background event that match the last parent view shown
        
        analytics.track(viewShown: step2)
        #expect(analytics.lastParentViewShown == step2)
        #expect(analytics.get(userProperty: .LAST_PARENT_VIEW_SHOWN) == "step 2;nil;onboarding;2;middle")

        analytics.track(viewShown: step3)
        #expect(analytics.lastParentViewShown == step3)
        #expect(analytics.get(userProperty: .LAST_PARENT_VIEW_SHOWN) == "step 3;nil;onboarding;3;end")
    }
    
}
