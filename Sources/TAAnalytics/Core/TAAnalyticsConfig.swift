//  TAAnalyticsConfig.swift
//  Created by Adi on 10/25/22
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

public struct TAAnalyticsConfig {
    public enum ProcessType: CaseIterable {
        /// running as an app
        case app
        /// running as an  app extension
        case appExtension
    }

    public enum InstallType: CaseIterable {
        /// installed from the App Store
        case AppStore
        /// installed from Xcode
        case Xcode
        /// installed from Xcode with Debugger Attached
        case XcodeAndDebuggerAttached
        /// installed from TestFlight
        case TestFlight
    }
    
    public struct PrefixConfig {
        let eventPrefix: String
        let userPropertyPrefix: String
        
        public init(eventPrefix: String,userPropertyPrefix: String) {
            self.eventPrefix = eventPrefix
            self.userPropertyPrefix = userPropertyPrefix
        }
    }
    
    public let adaptors: [any AnalyticsAdaptor]
    
    let analyticsVersion: String
    let currentProcessType: ProcessType
    let enabledProcessTypes: [ProcessType]
    let currentInstallType: InstallType
    let userDefaults: UserDefaults
    let installUserProperties: [UserPropertyAnalyticsModel]
    let maxTimeoutForAdaptorStart: Double
    let trackEventFilter: (( _ event: EventAnalyticsModel, _ params: [String: (any AnalyticsBaseParameterValue)?]?) -> Bool)

    /// Prefix for events/userProperties automatically tracked by this internal library. Those sent by your app via `track..`/`set(userProperty..` will not be prefixed
    let automaticallyTrackedEventsPrefixConfig: PrefixConfig
    /// Prefix for events/userProperties sent manually by you via `track..`/`set(userProperty..`
    let manuallyTrackedEventsPrefixConfig: PrefixConfig
    /// Custom flush interval that will overrride the default one for adaptors
    public let flushIntervalForAdaptors: TimeInterval?
    
    // TODO: adi install user properties and dynamic what
    
    ///
    /// - Parameters:
    ///   - analyticsVersion: Separate user property that tracks the version of the analytics events. Ideally, when you'd add/modify an event, this version would also be changed and communicated to the BI team, so that they know to only look for that specific event from analyticsVersion x.
    ///   - adaptors: analytics adaptors to use
    ///   - currentProcessType: defaults to `findProcessType()`
    ///   - enabledProcessTypes: what process types should have logging enabled. Defaults to `ProcessType.allCases`
    ///   - userDefaults: defaults to `UserDefaults.standard`
    ///   - instalUserProperties:
    ///   - maxTimeoutForAdaptorStart:
    ///   - automaticallyTrackedEventsPrefixConfig: Prefix for events/userProperties automatically tracked by this internal library. Those manually sent by the app via `track..`/`set(userProperty..` will not be prefixed
    ///   - manuallyTrackedEventsPrefixConfig: Prefix for events/userProperties sent manually by you via `track..`/`set(userProperty..`
    public init(analyticsVersion: String,
                adaptors: [any AnalyticsAdaptor],
                currentProcessType: ProcessType = findProcessType(),
                enabledProcessTypes: [ProcessType] = ProcessType.allCases,
                userDefaults: UserDefaults = UserDefaults.standard,
                instalUserProperties: [UserPropertyAnalyticsModel] = [.INSTALL_DATE, .INSTALL_VERSION, .INSTALL_OS_VERSION, .INSTALL_IS_JAILBROKEN, .INSTALL_UI_APPEARANCE, .INSTALL_DYNAMIC_TYPE],
                maxTimeoutForAdaptorStart: Double = 10,
                flushIntervalForAdaptors: TimeInterval? = nil,
                automaticallyTrackedEventsPrefixConfig: PrefixConfig = PrefixConfig(eventPrefix: "", userPropertyPrefix: ""),
                manuallyTrackedEventsPrefixConfig: PrefixConfig = PrefixConfig(eventPrefix: "", userPropertyPrefix: ""),
                trackEventFilter: @escaping (( _ event: EventAnalyticsModel, _ params: [String: (any AnalyticsBaseParameterValue)?]?) -> Bool) = { _ ,_ in true }
    ) {
        self.analyticsVersion = analyticsVersion
        self.adaptors = adaptors
        self.currentProcessType = currentProcessType
        self.enabledProcessTypes = enabledProcessTypes
        self.userDefaults = userDefaults
        self.currentInstallType = Self.findInstallType()
        self.installUserProperties = instalUserProperties
        self.maxTimeoutForAdaptorStart = maxTimeoutForAdaptorStart
        self.automaticallyTrackedEventsPrefixConfig = automaticallyTrackedEventsPrefixConfig
        self.manuallyTrackedEventsPrefixConfig = manuallyTrackedEventsPrefixConfig
        self.trackEventFilter = trackEventFilter
        self.flushIntervalForAdaptors = flushIntervalForAdaptors
    }
    
    /// Figures out if it's running as an app or app extension, by looking at the bundle's suffix
    public static func findProcessType() -> ProcessType {
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            return .app
        } else {
            return .appExtension
        }
    }
    
    public static func findInstallType() -> InstallType {
        if let receiptPath = Bundle.main.appStoreReceiptURL?.path {
            if FileManager.default.fileExists(atPath: receiptPath) {
                if receiptPath.contains("sandboxReceipt") {
                    return .TestFlight
                }
                return .AppStore
            }
        }
        return .Xcode
    }
}
