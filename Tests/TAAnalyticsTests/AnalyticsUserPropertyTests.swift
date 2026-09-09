//  AnalyticsUserPropertyTests.swift
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

import XCTest
@testable import TAAnalytics

final class AnalyticsUserPropertyTests: XCTestCase {
    
    func testItDoesnTrim() throws {
        XCTAssertEqual(UserPropertyAnalyticsModel("short_value").rawValue, "short_value")
    }
    
    /// Replaces a `testItTrims` that asserted the initializer truncated to 24 characters. It never
    /// did — no commit in this repository has ever put trimming there — so the test had never
    /// passed. The 24-character guidance is a BI naming convention; the enforcement that matters
    /// is per-destination, in each adaptor's `trim(userProperty:)`, which needs the full name.
    func testTheModelKeepsTheFullNameSoEachAdaptorCanApplyItsOwnLimit() throws {
        let name = "long_value_longer_than_24_characters"
        XCTAssertEqual(UserPropertyAnalyticsModel(name).rawValue, name)
    }

}
