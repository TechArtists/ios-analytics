//  TAAnalyticsTests.swift
//  Created by Adi on 10/24/22
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

import Testing
import Foundation
import UIKit
@testable import TAAnalytics

class TAAnalyticsUIEventsTests {
    
    let analytics: TAAnalytics
    let unitTestAdaptor : TAAnalyticsUnitTestAdaptor
    let notificationCenter = NotificationCenter.default
    
    init() async {
        UserDefaults.standard.removePersistentDomain(forName: "TATests")
        let mockUserDefaults = UserDefaults(suiteName: "TATests")!
        unitTestAdaptor = TAAnalyticsUnitTestAdaptor()
        analytics = TAAnalytics(
            config: TAAnalyticsConfig(
                analyticsVersion: "1",
                adaptors: [unitTestAdaptor],
                userDefaults: mockUserDefaults
            )
        )
        await analytics.start()
    }
        
    @Test
    func testLastViewShowOnlyRemembersMainViews() async throws {

        let step1 = ViewAnalyticsModel(name: "step 1", type: nil, funnelStep: AnalyticsViewFunnelStepDetails(funnelName: "onboarding", step: 1, isOptionalStep: false, isFinalStep: false))
        let step1SecondaryView = SecondaryViewAnalyticsModel(name: "incorrect email label", type: "foo", mainView: step1)
        let step2 = ViewAnalyticsModel(name: "step 2", type: nil, funnelStep: AnalyticsViewFunnelStepDetails(funnelName: "onboarding", step: 2, isOptionalStep: true, isFinalStep: false))
        let step3 = ViewAnalyticsModel(name: "step 3", type: nil, funnelStep: AnalyticsViewFunnelStepDetails(funnelName: "onboarding", step: 3, isOptionalStep: false, isFinalStep: true))

        
        analytics.track(viewShow: step1)
        analytics.track(viewShow: step1SecondaryView)

        // it should only keep track of parent views, not subviews
        #expect(analytics.lastViewShow == step1)
        
        // send another event, so that we can wait on it and test the LAST_VIEW_SHOW user property afterwards (to make sure it got executed from the queue)
        analytics.track(event: EventAnalyticsModel("dont care"))
        let _ = try await requireEvent(named: "dont care", matching: { _ in return true } )
        #expect(analytics.get(userProperty: .LAST_VIEW_SHOW) == "step 1;nil;onboarding;1;false;false")
        
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        let eventAppBackground = try await requireEvent(named: EventAnalyticsModel.APP_CLOSE.rawValue)
        let params = eventAppBackground.parameters
        
        if let lastViewShow = analytics.lastViewShow {
            #expect((params?["view_name"] as! String) == lastViewShow.name)
            #expect((params?["view_type"] as! String?) == lastViewShow.type)
            
            #expect((params?["view_funnel_name"] as! String) == lastViewShow.funnelStep?.funnelName)
            #expect((params?["view_funnel_step"] as! Int) == lastViewShow.funnelStep?.step)
            #expect((params?["view_funnel_step_is_optional"] as! Bool) == lastViewShow.funnelStep?.isOptionalStep)
            #expect((params?["view_funnel_step_is_final"] as! Bool) == lastViewShow.funnelStep?.isFinalStep)
            
        }
        
        analytics.track(viewShow: step2)
        #expect(analytics.lastViewShow == step2)
        #expect(analytics.get(userProperty: .LAST_VIEW_SHOW) == "step 2;nil;onboarding;2;true;false")

        analytics.track(viewShow: step3)
        #expect(analytics.lastViewShow == step3)
        #expect(analytics.get(userProperty: .LAST_VIEW_SHOW) == "step 3;nil;onboarding;3;false;true")
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
