//
//  Test.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 10.09.2024.
//

import Testing
import TAAnalytics
import Foundation

struct TAAnalyticsTestsMain {
    let ob = TAAnalytics(
        config: TAAnalyticsConfig(
            analyticsVersion: "1",
            
            platforms: [],
            userDefaults: UserDefaults(suiteName: "testSuite") ?? .standard
        )
    )
    
    init() {
        ob.start()
    }
    
    @Test func test_getNextCounterValueFrom_initiallyReturns0() async throws {
        let analyticsUserProperty = AnalyticsUserProperty("ui_screen_shown")
        
    }

}
