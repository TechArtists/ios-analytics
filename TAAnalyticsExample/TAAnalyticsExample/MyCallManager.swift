//  MyCallManager.swift
//  Created by Adi on 10/26/22.
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
import Foundation
import Contacts

import TAAnalytics
class MyCallManager {
    
    let analytics: TAAnalyticsProtocol
    
    init(analytics: TAAnalyticsProtocol) {
        self.analytics = analytics
    }
    
    
    /// It will "try" to call the desired phone number only if it doesn't have 4 digits
    /// Otherwise, it will
    func callIfAtLeastFourDigits(phoneNumber: String) {
        if phoneNumber.count >= 4 {
            // send only the last 4 digits for analytics purposes while preserving PII
            analytics.track(event: .CALL_PLACED, params: ["phone_number_suffix": String(phoneNumber.suffix(4))], logCondition: .logAlways)

            // actually place the call somehow
            // Carrier.placeCall(phoneNumber)
        } else {
            analytics.trackErrorEvent(reason: "call_not_placed", extraParams: ["reason": "not enough digits", "digits": phoneNumber.count])
        }
    }
    
    
}
