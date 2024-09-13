//  TAAnalytics.swift
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


// SPM forces us to have macOS as a platform in Package.swift
// but FirebaseAnalytics isn't available on macOS.
// Until that gets resolved, we'll have to leave this here
#if os(macOS)
import OSLog

internal let LOGGER = OSLog(subsystem: "TA", category: "TAAnalytics")

class TAAnalyticsNotObservable {

//    internal(set) public static var shared : AnalyticsProtocol!
//    internal init(state: AnalyticsState, isApp: Bool, userDefaults: UserDefaults) {}
}

#else
import UIKit
import OSLog

internal let LOGGER = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "TAAnalytics")

public class TAAnalytics: ObservableObject {
    public static let userdefaultsKeyPrefix = "TAAnalytics"
    public static let logger = LOGGER
    
    public private(set) var config: TAAnalyticsConfig
    
    internal var notificationCenterObservers = [Any]()
    internal var isFirstForeground = true
    
    internal var startedConsumers = [any AnalyticsConsumer]()
    
    /// Events sent during this session that had the specific log condition of `.logOnlyOncePerAppSession`
    internal var appSessionEvents = Set<AnalyticsEvent>()
    
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
        firstOpenParameterCallback: (() -> [String: AnalyticsBaseParameterValue]?)? = nil
    ) async {
        logStartupDetails()
        
        await startConsumers()
        
        configureUserProperties()
        
        incrementLoadCount()

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
        os_log("Starting with install type: '%{public}@', process type '%{public}@', enabled process types '%{public}@'",
               log: LOGGER,
               type: .info,
               String(describing: config.currentInstallType),
               String(describing: config.currentProcessType),
               String(describing: config.enabledProcessTypes)
        )
    }

    //TODO: create a maximum timeout for consumers to start
    private func startConsumers() async {
        let startedConsumers = await withTaskGroup(of: (any AnalyticsConsumer)?.self) { group in
            for consumer in config.consumers {
                group.addTask {
                    do {
                        try await consumer.startFor(
                            installType: self.config.currentInstallType,
                            userDefaults: self.config.userDefaults,
                            TAAnalytics: self
                        )
                        os_log("Consumer: '%{public}@' has been started", log: LOGGER, type: .info, String(describing: consumer))
                        return consumer
                    } catch {
                        os_log(
                            "Consumer: '%{public}@' did NOT start for this install types: '%{public}@' and threw error: '%{public}@'",
                            log: LOGGER,
                            type: .info,
                            String(describing: consumer),
                            String(describing: self.config.currentInstallType),
                            error.localizedDescription
                        )
                        return nil
                    }
                }
            }
            
            return await group.reduce(into: [any AnalyticsConsumer]()) { partialResult, consumer in
                if let consumer = consumer {
                    partialResult.append(consumer)
                }
            }
        }
        
        self.startedConsumers = startedConsumers
    }

    private func configureUserProperties() {
        set(userProperty: .ANALYTICS_VERSION, to: self.config.analyticsVersion)
        set(userProperty: .COLD_APP_LAUNCH_ID, to: "\(self.getNextCounterValueFrom(userProperty: .COLD_APP_LAUNCH_ID))")
        set(userProperty: .FOREGROUND_ID, to: "0")
    }

    private func handleFirstOpen(
        customInstallUserPropertiesCompletion: (() -> ())? = nil,
        shouldLogFirstOpen: Bool = true,
        firstOpenParameterCallback: (() -> [String: AnalyticsBaseParameterValue]?)? = nil
    ) {
        os_log("Is first open", log: LOGGER, type: .info)
        
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

    private func logFirstOpen(firstOpenParameterCallback: (() -> [String: AnalyticsBaseParameterValue]?)?) {
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
    
    internal func getNextCounterValueFrom(userProperty: AnalyticsUserProperty) -> Int{
        if let existingLaunchID = self.get(userProperty: userProperty),
           let previousLaunchID = Int(existingLaunchID){
            return previousLaunchID + 1
        }
        return 0
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
