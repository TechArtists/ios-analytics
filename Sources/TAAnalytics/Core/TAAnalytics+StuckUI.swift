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

//private struct AssociatedKeys {
//    static var stuckTimer = "stuckTimerKey"
//}

public protocol TAAnalyticsStuckUIProtocol: TAAnalyticsBaseProtocol {
    
    var stuckTimer: Timer? { get set }
    var correctionStuckTimer: Timer? { get set }
}

// MARK: - Default Implementations

internal extension TAAnalyticsStuckUIProtocol {
    
    var stuckViewParamsKey: String { "stuckViewParams" }
    
    func trackCorrectedStuckEventIfNeeded(viewName: String) {
        guard correctionStuckTimer?.isValid ?? false else { return }
        
        if let params = UserDefaults.standard.dictionary(forKey: stuckViewParamsKey) {
            let convertedParams = params.mapValues { value -> Any in
                if let nsString = value as? NSString {
                    return String(nsString)
                }
                return value
            }

            let castedParams = convertedParams.compactMapValues { $0 as? (any AnalyticsBaseParameterValue) }
            
            if !castedParams.isEmpty {
                track(event: .corrected_error_stuck_on_ui_view_show, params: castedParams, logCondition: .logAlways)
                cancelCorrectionStuckTimer()
            }
        }
    }
    
    func cancelStuckTimer() {
        DispatchQueue.main.async {
            self.stuckTimer?.invalidate()
            self.stuckTimer = nil
        }
    }
    
    func cancelCorrectionStuckTimer() {
        DispatchQueue.main.async {
            self.correctionStuckTimer?.invalidate()
            self.correctionStuckTimer = nil
        }
    }
    
    func scheduleStuckTimer(delay: TimeInterval, viewName: String) {
        DispatchQueue.main.async {
            self.stuckTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                self?.handleStuckTimerExpired(delayStuck: delay)
            }
        }
    }
    
    func scheduleCorrectionTimer() {
        DispatchQueue.main.async {
            self.correctionStuckTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: { _ in })
        }
    }
    
    func handleStuckTimerExpired( delayStuck: TimeInterval) {
        if let params = UserDefaults.standard.dictionary(forKey: stuckViewParamsKey) {
            let convertedParams = params.mapValues { value -> Any in
                if let nsString = value as? NSString {
                    return String(nsString)
                }
                return value
            }

            var castedParams = convertedParams.compactMapValues { $0 as? (any AnalyticsBaseParameterValue) }
            
            castedParams["duration"] = delayStuck
            
            if !castedParams.isEmpty {
                track(event: .error_stuck_on_ui_view_show, params: castedParams, logCondition: .logAlways)
                scheduleCorrectionTimer()
            }
        }
        cancelStuckTimer()
    }
}

// MARK: - Empty Conformance

extension TAAnalytics : TAAnalyticsStuckUIProtocol {}
