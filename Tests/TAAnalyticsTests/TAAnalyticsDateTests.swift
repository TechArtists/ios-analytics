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
import XCTest
@testable import TAAnalytics

final class TAAnalyticsDateTests: XCTestCase {
    let ob = TAAnalytics(config: TAAnalyticsConfig(analyticsVersion: "1", consumers: []))
    
    func testRelativeAgeForUnder24h() throws {
        let formatter = ISO8601DateFormatter()
        
        let startDate = formatter.date(from: "2022-01-01T20:59:59Z")!
        let endDate1  = formatter.date(from: "2022-01-01T21:59:59Z")!
        let endDate2  = formatter.date(from: "2022-01-02T00:01:59Z")!
        let endDate3  = formatter.date(from: "2022-01-02T20:59:58Z")!
        
        XCTAssertEqual(0,ob.relativeAgeBetween(startDate: startDate, endDate: endDate1))
        XCTAssertEqual(0,ob.relativeAgeBetween(startDate: startDate, endDate: endDate2))
        XCTAssertEqual(0,ob.relativeAgeBetween(startDate: startDate, endDate: endDate3))
    }

    func testRelativeAgeForOver24h() throws {
        let formatter = ISO8601DateFormatter()
        
        let startDate = formatter.date(from: "2022-01-01T20:59:59Z")!
        
        let endDate1  = formatter.date(from: "2022-01-02T21:00:00Z")!
        let endDate2  = formatter.date(from: "2022-01-03T20:59:59Z")!
        let endDate3  = formatter.date(from: "2022-01-03T21:00:00Z")!
        let endDate4  = formatter.date(from: "2022-01-03T22:00:00Z")!
        let endDate5  = formatter.date(from: "2022-01-04T05:00:00Z")!
        
        
        XCTAssertEqual(1,ob.relativeAgeBetween(startDate: startDate, endDate: endDate1))
        XCTAssertEqual(2,ob.relativeAgeBetween(startDate: startDate, endDate: endDate2))
        XCTAssertEqual(2,ob.relativeAgeBetween(startDate: startDate, endDate: endDate3))
        XCTAssertEqual(2,ob.relativeAgeBetween(startDate: startDate, endDate: endDate4))
        XCTAssertEqual(2,ob.relativeAgeBetween(startDate: startDate, endDate: endDate5))
    }
    
    func testCalendarAgeForUnder24h() throws {
        let formatter = ISO8601DateFormatter()
        let utc = TimeZone(abbreviation: "UTC")!
        
        let startDate = formatter.date(from: "2022-01-01T20:59:59Z")!
        let endDate1  = formatter.date(from: "2022-01-01T21:59:59Z")!
        let endDate2  = formatter.date(from: "2022-01-02T00:01:59Z")!
        let endDate3  = formatter.date(from: "2022-01-02T20:59:58Z")!

        
        XCTAssertEqual(0,ob.calendarAgeBetween(startDate: startDate, endDate: endDate1, timeZone: utc))
        XCTAssertEqual(1,ob.calendarAgeBetween(startDate: startDate, endDate: endDate2, timeZone: utc))
        XCTAssertEqual(1,ob.calendarAgeBetween(startDate: startDate, endDate: endDate3, timeZone: utc))
    }
    
    func testCalendarAgeForOver24h() throws {
        let formatter = ISO8601DateFormatter()
        let utc = TimeZone(abbreviation: "UTC")!

        let startDate = formatter.date(from: "2022-01-01T20:59:59Z")!
        
        let endDate1  = formatter.date(from: "2022-01-02T21:00:00Z")!
        let endDate2  = formatter.date(from: "2022-01-03T20:59:59Z")!
        let endDate3  = formatter.date(from: "2022-01-03T21:00:00Z")!
        let endDate4  = formatter.date(from: "2022-01-03T22:00:00Z")!
        let endDate5  = formatter.date(from: "2022-01-04T05:00:00Z")!

        
        XCTAssertEqual(1,ob.calendarAgeBetween(startDate: startDate, endDate: endDate1, timeZone: utc))
        XCTAssertEqual(2,ob.calendarAgeBetween(startDate: startDate, endDate: endDate2, timeZone: utc))
        XCTAssertEqual(2,ob.calendarAgeBetween(startDate: startDate, endDate: endDate3, timeZone: utc))
        XCTAssertEqual(2,ob.calendarAgeBetween(startDate: startDate, endDate: endDate4, timeZone: utc))
        XCTAssertEqual(3,ob.calendarAgeBetween(startDate: startDate, endDate: endDate5, timeZone: utc))
    }


}
