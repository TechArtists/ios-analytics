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
import TAAnalytics

class TAAnalyticsBase {
    let analytics: TAAnalytics
    let unitTestConsumer : TAAnalyticsUnitTestConsumer
    let notificationCenter = NotificationCenter.default
    
    init() {
        UserDefaults.standard.removePersistentDomain(forName: "TATests")
        let mockUserDefaults = UserDefaults(suiteName: "TATests")!
        unitTestConsumer = TAAnalyticsUnitTestConsumer()
        analytics =  TAAnalytics(config: .init(analyticsVersion: "0", consumers: [], userDefaults: mockUserDefaults))
    }

    @Test
    func testThatNilsAreNotSentToConsumers() {

        var params = [String: AnalyticsBaseParameterValue?]()
        params["key1"] = "value1"
        params["key2"] = nil
        params["key3"] = "value3"
        
        
        analytics.track(event: .FIRST_OPEN, params: params, logCondition: .logAlways)
        
        // TODO: confirm that the only parameters sent are key1 & key3
        #expect(unitTestConsumer.eventsSent[0].params.count == 2)
        #expect((unitTestConsumer.eventsSent[0].params["key1"] as! String) == "value1")
        #expect(unitTestConsumer.eventsSent[0].params["key2"] == nil)
        #expect((unitTestConsumer.eventsSent[0].params["key3"] as! String) == "value3")
    }

    
}
