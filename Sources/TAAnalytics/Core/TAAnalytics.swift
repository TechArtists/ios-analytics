//  TAAnalytics.swift
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


// SPM forces us to have macOS as a platform in Package.swift
// but FirebaseAnalytics isn't available on macOS.
// Until that gets resolved, we'll have to leave this here
#if os(macOS)
import OSLog

internal let LOGGER = OSLog(subsystem: "TA", category: "TAAnalytics")

#else
import UIKit
import OSLog

internal let LOGGER = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "TAAnalytics")

public class TAAnalytics: ObservableObject {
    public static let userdefaultsKeyPrefix = "TAAnalytics"
    public static let logger = LOGGER
    
    public private(set) var config: TAAnalyticsConfig
    
    internal var notificationCenterObservers = [Any]()
    
    internal var eventQueueBuffer: EventBuffer = .init(allConsumers: [])
    
    /// Events sent during this session that had the specific log condition of `.logOnlyOncePerAppSession`
    internal var appSessionEvents = Set<EventAnalyticsModel>()
    
    public var lastViewShow: ViewAnalyticsModel?
    
    public var stuckUIManager: StuckUIManager?
    
    public init(config: TAAnalyticsConfig) {
        self.config = config
    }
    
    /// - Parameters:
    ///   - customInstallUserPropertiesCompletion: completion called before logging the `first open` event. Use this to set any custom install time user properties specific to your app, that are not available by default via `TAAnalyticsConfig#instalUserProperties`
    ///   - shouldLogFirstOpen: if the first open event should be logged. Normally you want this set to `true`, but in some instances, if this is called in `AppDelegate#didFinishLaunching`, a specific parameter you'd want to might not be available. In that case, set this to `false` and then manually call `TAAnalytics#maybeLogTAFirstOpen` when you have all the data
    ///   - firstOpenParameterCallback: if `shouldLogFirstOpen` is `true`, then this will be called only when trying to send the `first open` event. It's set as a callback instead of getting the parameters directly so that any (expensive) operations in the parameter calculation will only be performed when necessary.
    public func start(
        customInstallUserPropertiesCompletion: (() -> ())? = nil,
        shouldLogFirstOpen: Bool = true,
        firstOpenParameterCallback: (() -> [String: any AnalyticsBaseParameterValue]?)? = nil
    ) async {
        logStartupDetails()
        
        await startConsumers()
        
        configureUserProperties()
        
        incrementLoadCount()
        
        sendAppVersionEventUpdatedIfNeeded()
        
        sendOSUpdateEventIFNeeded()

        if isFirstOpen {
            handleFirstOpen(
                customInstallUserPropertiesCompletion: customInstallUserPropertiesCompletion,
                shouldLogFirstOpen: shouldLogFirstOpen,
                firstOpenParameterCallback: firstOpenParameterCallback
            )
        }
        
        addAppLifecycleObservers()
    }
    
    private func logStartupDetails() {
        TALogger.log("Starting with install type: '\(String(describing: config.currentInstallType))', process type '\(String(describing: config.currentProcessType))', enabled process types '\(String(describing: config.enabledProcessTypes))'", level: .info)
    }
    
    private func startConsumers() async {
         let startedConsumers = await withTaskGroup(of: (any AnalyticsConsumer)?.self) { group in
            for consumer in config.consumers {
                group.addTask {
                    do {
                        try await withThrowingTimeout(seconds: self.config.maxTimeoutForConsumerStart) {
                            if consumer is EventEmitterConsumer {
                                try await Task.sleep(seconds: 4)
                            }
                            
                            try await consumer.startFor(
                                installType: self.config.currentInstallType,
                                userDefaults: self.config.userDefaults,
                                TAAnalytics: self
                            )
                        }
                        
                        TALogger.log("Consumer: '\(String(describing: consumer))' has been started", level: .info)
                        return consumer
                    } catch is TimeoutError {
                        TALogger.log("Consumer: '\(String(describing: consumer))' did NOT start because maximum start timeout of '\(String(describing: self.config.maxTimeoutForConsumerStart))' seconds was reached", level: .info)
                        return nil
                    } catch {
                        TALogger.log("Consumer: '\(String(describing: consumer))' did NOT start for this install type: '\(String(describing: self.config.currentInstallType))' and threw error: '\(error.localizedDescription)'", level: .info)

                        return nil
                    }
                }
            }

             return await group.compactMap{ $0 }.reduce(into: []) { $0.append($1) }
        }
        
        await self.eventQueueBuffer.setupConsumers(with: startedConsumers)
    }
    
    private func sendAppVersionEventUpdatedIfNeeded() {
        guard
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else {
            return
        }

        let defaultsAppVersion = stringFromUserDefaults(forKey: "appVersion")
        let defaultsBuild = stringFromUserDefaults(forKey: "build")

        // Check and update app version
        if defaultsAppVersion != appVersion || defaultsBuild != build {

            setInUserDefaults(appVersion, forKey: "appVersion")
            setInUserDefaults(build, forKey: "build")

            track(event: .APP_VERSION_UPDATE,
                  params: [ "from_version": defaultsAppVersion,
                            "to_version": appVersion,
                            "from_build": defaultsBuild,
                            "to_build": build
            ])
        }
    }
    
    private func sendOSUpdateEventIFNeeded() {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        let osString = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        
        let defaultsOSVersion = stringFromUserDefaults(forKey: "osVersion")
        
        if defaultsOSVersion != osString {
            setInUserDefaults(osString, forKey: "osVersion")
            if let defaultsOSVersion {
                track(event: .OS_VERSION_UPDATE,
                      params: ["from_version": defaultsOSVersion,
                               "to_version": osString,
                ])
            }
        }
    }

    private func configureUserProperties() {
        set(userProperty: .ANALYTICS_VERSION, to: self.config.analyticsVersion)
        set(userProperty: .APP_COLD_LAUNCH_COUNT, to: "\(self.getNextCounterValueFrom(userProperty: .APP_COLD_LAUNCH_COUNT))")
    }

    private func handleFirstOpen(
        customInstallUserPropertiesCompletion: (() -> ())? = nil,
        shouldLogFirstOpen: Bool = true,
        firstOpenParameterCallback: (() -> [String: any AnalyticsBaseParameterValue]?)? = nil
    ) {
        TALogger.log("Is first open", level: .info)
        
        calculateAndSetUserProperties()
        
        customInstallUserPropertiesCompletion?()
        
        if shouldLogFirstOpen {
            logFirstOpen(firstOpenParameterCallback: firstOpenParameterCallback)
        }
        
        synchronizeUserID()
    }

    private func calculateAndSetUserProperties() {
        let calculator = DefaultInstallUserPropertiesCalculator(
            analytics: self,
            userPropertiesToCalculate: self.config.instalUserProperties
        )
        calculator.calculateUserPropertiesAndSetThem()
    }

    private func logFirstOpen(firstOpenParameterCallback: (() -> [String: any AnalyticsBaseParameterValue]?)?) {
        let firstOpenParams = firstOpenParameterCallback?()
        maybeLogTAFirstOpen { return firstOpenParams }
    }

    // set user id & re-set user properties

    // if this is an extension, then this will make sure that the userID in the extension
    // is the same as the one from the shared user defaults (provided that a shared user defaults was passed to this)
    private func synchronizeUserID() {
        let existingUserIDFromUserDefaults = self.userID
        self.userID = existingUserIDFromUserDefaults
    }
    
    
    /// It reads the value of the user property from UserDefaults, expecting it to be an int
    /// - Parameters:
    ///   - defaultIfNotExists: defaults to 1 and is returned if there is no valid int saved in UserDefaults
    /// - Returns: the existing value from UserDefaults incremented by 1. Note that this will not save the new value in UserDefaults.
    internal func getNextCounterValueFrom(userProperty: UserPropertyAnalyticsModel, defaultIfNotExists: Int = 1) -> Int{
        if let existingLaunchID = self.get(userProperty: userProperty),
           let previousLaunchID = Int(existingLaunchID){
            return previousLaunchID + 1
        }
        return defaultIfNotExists
    }
    
    // Helper function to fetch the stored dictionary
    private func fetchStoredDictionary() -> [String: Any] {
        if let storedDict = self.config.userDefaults.dictionary(forKey: Self.userdefaultsKeyPrefix) {
            return storedDict
        }
        return [:]
    }
    
    private func saveDictionaryToUserDefaults(_ dict: [String: Any]) {
        self.config.userDefaults.set(dict, forKey: Self.userdefaultsKeyPrefix)
    }
    
    public func stringFromUserDefaults(forKey key: String) -> String? {
        let storedDict = fetchStoredDictionary()
        return storedDict[key] as? String
    }
    
    public func boolFromUserDefaults(forKey key: String) -> Bool? {
        let storedDict = fetchStoredDictionary()
        return storedDict[key] as? Bool
    }
    
    public func integerFromUserDefaults(forKey key: String) -> Int? {
        let storedDict = fetchStoredDictionary()
        return storedDict[key] as? Int
    }
    
    public func objectFromUserDefaults(forKey key: String) -> Any? {
        let storedDict = fetchStoredDictionary()
        return storedDict[key]
    }
    
    public func setInUserDefaults(_ value: Any?, forKey key: String) {
        var storedDict = fetchStoredDictionary()
        if let value = value {
            storedDict[key] = value
        } else {
            storedDict.removeValue(forKey: key)
        }
        saveDictionaryToUserDefaults(storedDict)
    }
}

#endif
