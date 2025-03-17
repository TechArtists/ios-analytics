/*
MIT License

Copyright (c) 2025 Tech Artists Agency

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//  TAAnalytics+OpenCounts.swift
//  Created by Adi on 10/25/22
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

import Foundation

// MARK: -

public protocol TAAnalyticsOpenCountsProtocol {
    /// The load count for the specific app/extension. The very first load has a count of 1
    var loadCount: Int { get }
    
    /// If this is the first open for the specific app/extension
    var isFirstOpen: Bool { get }
    
    /// The number of days since the app was installed. Age 0 means that it's within the first 24h of it being installed
    var installAgeRelativeTime: Int? { get }

    /// The number of calendar days since the app was installed. Age 0 means that it's the same day.
    /// If a user installs the app at 23:59:59 UTC, 1 minute later this `installAgeCalendar` will be 1
    var installAgeLocalizedCalendar: Int? { get }
    

    /// It sends the `ob app open` event if this is the first app open event.
    /// Note that this will only be sent from the `app`, not from extensions
    ///
    /// - Parameter paramsCallback: any specific parameters you want to anotate the `ob app open` event with.  It's modeled as a callback so that the expensive parameters you want to add on `ob first open` won't be calculated each time
    /// - Returns: if the first open event was sent or not
    @discardableResult func maybeLogTAFirstOpen(paramsCallback: () -> [String: (any AnalyticsBaseParameterValue)]?) -> Bool
}

public extension TAAnalyticsOpenCountsProtocol {
    var isFirstOpen: Bool {
        return loadCount == 1
    }
}

// MARK: -

extension TAAnalytics: TAAnalyticsOpenCountsProtocol {
    
    public var loadCount: Int {
        return self.integerFromUserDefaults(forKey: loadCountKey) ?? 0
    }
    
    internal func incrementLoadCount() {
        let newLoadCount = loadCount + 1
        self.setInUserDefaults(newLoadCount, forKey: loadCountKey)

        self.setInUserDefaults(Date(), forKey: "installDate")
    }
    
    private var loadCountKey : String {
        var key = "appLoadCount"
        // this bundle ID will be specific for the app or each extension
        if let bundleID = Bundle.main.bundleIdentifier {
            key = "\(bundleID)_appLoadCount"
        }
        return key
    }
    
    
    public var installAgeRelativeTime: Int? {
        if let startDate = self.objectFromUserDefaults(forKey: "installDate") as? Date {
            return relativeAgeBetween(startDate: startDate, endDate: Date())
        }
        return nil
    }
    
    internal func relativeAgeBetween(startDate: Date, endDate: Date) -> Int {
        let timePassed = endDate.timeIntervalSince(startDate)
        let daysPassed = Int(timePassed) / (24 * 60 * 60)
        return daysPassed
    }
    
    
    public var installAgeLocalizedCalendar: Int? {
        if let startDate = self.objectFromUserDefaults(forKey: "installDate") as? Date {
            return calendarAgeBetween(startDate: startDate, endDate: Date(), timeZone: TimeZone.current)
        }
        return nil
    }
    
    internal func calendarAgeBetween(startDate: Date, endDate: Date, timeZone: TimeZone) -> Int? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        let startDateDayStart = calendar.startOfDay(for: startDate)
        let endDateDayStart = calendar.startOfDay(for: endDate)
        
        let numberOfDays = calendar.dateComponents([.day], from: startDateDayStart, to: endDateDayStart)
        return numberOfDays.day
    }
    
    
    @discardableResult public func maybeLogTAFirstOpen(paramsCallback: () -> [String: (any AnalyticsBaseParameterValue)]?) -> Bool {
        if config.currentProcessType == .app && isFirstOpen {
            let params = paramsCallback()
            track(event: .FIRST_OPEN, params: params, logCondition: .logOnlyOncePerLifetime)
            return true
        }
        return false
    }

}
