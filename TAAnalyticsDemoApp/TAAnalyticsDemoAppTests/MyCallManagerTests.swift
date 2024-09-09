//
//  TAAnalyticsDemoAppTests.swift
//  TAeAnalyticsDemoAppTests
//
//  Created by Adi on 10/25/22.
//

import XCTest
import TAAnalytics
@testable import TAAnalyticsDemoApp

final class MyCallManagerTests: XCTestCase {

    func testCallingGoodNumber() throws {
        let mockAnalytics = MockTAAnalyticsPlatform()
        let callManager = MyCallManager(analytics: mockAnalytics)
        
        callManager.callTenDigit(phoneNumber: "1234567890")
        XCTAssertEqual(mockAnalytics.eventsSent.last?.event, AnalyticsEvent.CALL_PLACED)
    }

    func testCallingBadNumber() throws {
        let mockAnalytics = MockTAAnalyticsPlatform()
        let callManager = MyCallManager(analytics: mockAnalytics)
        
        callManager.callTenDigit(phoneNumber: "1234")
        XCTAssertTrue(mockAnalytics.eventsSent.last?.event.rawValue.starts(with: "error_") == true)
    }

}
