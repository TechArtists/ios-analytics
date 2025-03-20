//
//  TAAnalytics+StuckUI.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 16.01.2025.
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

public protocol TAAnalyticsStuckUIProtocol: TAAnalyticsErrorProtocol, TAAnalyticsBaseProtocol {
    var stuckUIManager: StuckUIManager? { get set }
}

// MARK: - Empty Conformance

extension TAAnalytics : TAAnalyticsStuckUIProtocol {}

// MARK: - 

public class StuckUIManager {
    internal static var REASON: String { "stuck on ui_view_show" }

    let analytics: any TAAnalyticsErrorProtocol
    
    let viewParams: [String: (any AnalyticsBaseParameterValue)]
    let initialDelay: TimeInterval
    
    var stuckTimer: Timer?
    var waitingForCorrectionAfterStuckStartDate: Date?

    internal init(viewParams: [String: (any AnalyticsBaseParameterValue)], initialDelay: TimeInterval, analytics: any TAAnalyticsErrorProtocol) {
        self.viewParams = viewParams
        self.initialDelay = initialDelay
        self.analytics = analytics
        self.waitingForCorrectionAfterStuckStartDate = nil
        self.stuckTimer = Timer.scheduledTimer(withTimeInterval: initialDelay, repeats: false) { [weak self] _ in
            self?.handleStuckTimerExpired()
        }
    }
    
    func handleStuckTimerExpired() {
        var newParams = [String: (any AnalyticsBaseParameterValue)]()
        viewParams.forEach({ key, value in newParams["view_\(key)"] = value })
        newParams["duration"] = initialDelay
            
        analytics.trackErrorEvent(reason: Self.REASON, error: nil, extraParams: newParams)
        markCorrectionStart()
        
        self.stuckTimer = nil
    }
    
    func markCorrectionStart() {
        self.waitingForCorrectionAfterStuckStartDate = Date()
    }
    
    func trackCorrectedStuckEventIfNeeded() {
        guard let correctionStartDate = waitingForCorrectionAfterStuckStartDate,
              Date().timeIntervalSince(correctionStartDate) <= 30 else { return }

        var newParams = [String: (any AnalyticsBaseParameterValue)]()
        viewParams.forEach({ key, value in newParams["view_\(key)"] = value })
        newParams["duration"] = initialDelay + Date().timeIntervalSince(correctionStartDate)

        analytics.trackErrorCorrectedEvent(reason: Self.REASON, error: nil, extraParams: newParams)
    }
    
    deinit {
        stuckTimer?.invalidate()
    }
}
