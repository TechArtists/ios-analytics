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
//  FITNESS FOR A00 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Testing
import Foundation
import UIKit
@testable import TAAnalytics

class TAAnalyticsUIEventsTests {
    
    let analytics: TAAnalytics
    let unitTestConsumer : TAAnalyticsUnitTestConsumer
    let notificationCenter = NotificationCenter.default
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATests")
        let mockUserDefaults = UserDefaults(suiteName: "TATests")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer()
        analytics = TAAnalytics(
            config: TAAnalyticsConfig(
                analyticsVersion: "1",
                consumers: [unitTestConsumer],
                userDefaults: mockUserDefaults
            )
        )
        await analytics.start()
    }
        
    @Test
    func testLastViewShowOnlyRemembersParentViews() async throws {

        let step1 = AnalyticsView(name: "step 1", type: nil, groupDetails: AnalyticsViewGroupDetails(name: "onboarding", order: 1, isFinalScreen: false))
        let step1Subview = AnalyticsView(name: "incorrect email label", type: "foo", parentView: step1)
        let step2 = AnalyticsView(name: "step 2", type: nil, groupDetails: AnalyticsViewGroupDetails(name: "onboarding", order: 2, isFinalScreen: false))
        let step3 = AnalyticsView(name: "step 3", type: nil, groupDetails: AnalyticsViewGroupDetails(name: "onboarding", order: 3, isFinalScreen: true))

        analytics.track(viewShow: step1)
        analytics.track(viewShow: step1Subview)
        // TODO: test that sending the step1 subview does not have any "group_" parameters on it
        // (impossible due to the separate the swift initializers, but we should test it in case someone refactors the initializers in the future)
        // . Only the "parent_view" parameters populated
        let deferredEvent = try await requireEvent(named: "ui_view_show", matching: {
            if let eventName = $0.parameters?["name"],
               let stringEventName = eventName as? String {
                return stringEventName == "incorrect email label"
            }

            return false
        })
        
        #expect(deferredEvent.parameters?.keys.contains(where: { $0.hasPrefix("group_") }) == false)

        // it should only keep track of parent views, not subviews
        #expect(analytics.lastParentViewShown == step1)
        #expect(analytics.get(userProperty: .LAST_PARENT_VIEW_SHOWN) == "step 1;nil;onboarding;1;start")
        
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // TODO: verify the parameters on the .app_background event that match the last parent view shown
        let eventAppBackground = try await requireEvent(named: "ta_app_background")
        let params = eventAppBackground.parameters
        
        if let lastParentViewShown = analytics.lastParentViewShown {
            #expect((params?["last_parent_view_name"] as! String) == lastParentViewShown.name)
            #expect((params?["last_parent_view_type"] as! String?) == lastParentViewShown.type)
            
            #expect((params?["last_parent_view_group_name"] as! String) == lastParentViewShown.groupDetails?.name)
            #expect((params?["last_parent_view_group_order"] as! Int) == lastParentViewShown.groupDetails?.order)
            #expect((params?["last_parent_view_group_stage"] as! String) == lastParentViewShown.groupDetails?.stage.description)
        }
        
        analytics.track(viewShow: step2)
        #expect(analytics.lastParentViewShown == step2)
        #expect(analytics.get(userProperty: .LAST_PARENT_VIEW_SHOWN) == "step 2;nil;onboarding;2;middle")

        analytics.track(viewShow: step3)
        #expect(analytics.lastParentViewShown == step3)
        #expect(analytics.get(userProperty: .LAST_PARENT_VIEW_SHOWN) == "step 3;nil;onboarding;3;end")
    }
    
    func requireEvent(
        named eventName: String,
        matching predicate: @escaping (DeferredQueuedEvent) -> Bool = { _ in true },
        timeout: TimeInterval = 3
    ) async throws -> DeferredQueuedEvent {
        try await withThrowingTimeout(seconds: timeout) {
            for await deferredEvent in analytics.eventQueueBuffer.passthroughStream.stream {
                guard deferredEvent.event.rawValue == eventName else { continue }

                if predicate(deferredEvent) {
                    return deferredEvent
                }
            }

            Issue.record("No event found for \(eventName)")
            throw EventStreamError.eventNotFound
        }
    }
}
