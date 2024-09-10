//  TAAnalytics.swift
//  Created by Adi on 10/24/22
//
//  Copyright (c) 2022 Tecj Artists Agenyc SRL (http://TA.com/)
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

//@available(iOS 13.0, *)
//public class TAAnalytics: TAAnalyticsCompat, ObservableObject {
//}

/// It's for backwards compatibility purposes, it does not implement the ObservableObject protocol
public class TAAnalytics: ObservableObject {
    public static let userdefaultsKeyPrefix = "TAAnalytics"
    public static let logger = LOGGER
    
    public private(set) var config: TAAnalyticsConfig
    
    internal var notificationCenterObservers = [Any]()
    internal var isFirstForeground = true
    
    internal var startedPlatforms = [AnalyticsConsumer]()
    
    /// Events sent during this session that had the specific log condition of `.logOnlyOncePerAppSession`
    internal var appSessionEvents = Set<AnalyticsEvent>()
    
    public init(config: TAAnalyticsConfig) {
        self.config = config
    }
    
    /// - Parameters:
    ///   - beforeLoggingFirstOpenCompletion: completion called before logging the `first open` event. Use this to set any custom install time user properties specific to your app, that are not available by default via `TAAnalyticsConfig#instalUserProperties`
    ///   - shouldLogFirstOpen: if the first open event should be logged. Normally you want this set to `true`, but in some instances, if this is called in `AppDelegate#didFinishLaunching`, a specific parameter you'd want to might not be available. In that case, set this to `false` and then manually call `TAAnalytics#maybeLogTAFirstOpen` when you have all the data
    ///   - firstOpenParameterCallback: if `shouldLogFirstOpen` is `true`, then this will be called only when trying to send the `first open` event. It's set as a callback instead of getting the parameters directly so that any (expensive) operations in the parameter calculation will only be performed when necessary.
    public func start(beforeLoggingFirstOpenCompletion: (() -> ())? = nil,
                      shouldLogFirstOpen: Bool = true,
                      firstOpenParameterCallback: (() -> [String: AnalyticsBaseParameterValue]?)? = nil ) {
        os_log("Starting with install type: '%{public}@', process type '%{public}@', enabled process types '%{public}@'"
               , log: LOGGER
               , type: .info
               , String(describing: config.currentInstallType)
               , String(describing: config.currentProcessType)
               , String(describing: config.enabledProcessTypes)
        )
        
        // TODO:
        for platform in config.platforms {
            if platform.maybeStartFor(installType: config.currentInstallType, userDefaults: config.userDefaults, TAAnalytics: self){
                os_log("Platform: '%{public}@' has been started", log: LOGGER, type: .info, String(describing: platform))
                startedPlatforms.append(platform)
            } else {
                os_log("Platform: '%{public}@' did NOT start for these conditions", log: LOGGER, type: .info, String(describing: platform))
            }
        }
        
        set(userProperty: .ANALYTICS_VERSION, to: self.config.analyticsVersion)
        self.set(userProperty: .COLD_APP_LAUNCH_ID, to: "\(self.getNextCounterValueFrom(userProperty: .COLD_APP_LAUNCH_ID))")
        self.set(userProperty: .FOREGROUND_ID, to: "0")

        incrementLoadCount()
        
        if isFirstOpen {
            os_log("Is first open", log: LOGGER, type: .info)

            let calculator = DefaultInstallUserPropertiesCalculator(analytics: self,
                                                                    userPropertiesToCalculate: self.config.instalUserProperties)
            calculator.calculateUserPropertiesAndSetThem()
 
            beforeLoggingFirstOpenCompletion?()

            if shouldLogFirstOpen {
                let firstOpenParams = firstOpenParameterCallback?()
                maybeLogTAFirstOpen { return firstOpenParams }
            }
            
            // set user id & re-set user properties

            // if this is an extension, then this will make sure that the userID in the extension
            // is the same as the one from the shared user defaults (provided that a shared user defaults was passed to this)
            let existingUserIDFromUserDefaults = self.userID
            self.userID = existingUserIDFromUserDefaults
        }
        
        addAppLifecycleObservers()
    }
    
    internal func getNextCounterValueFrom(userProperty: AnalyticsUserProperty) -> Int{
        if let existingLaunchID = self.get(userProperty: userProperty),
           let previousLaunchID = Int(existingLaunchID){
            return previousLaunchID + 1
        }
        return 0
    }
    
    public func stringFromUserDefaults(forKey key: String) -> String? {
        return self.config.userDefaults.string(forKey: "\(Self.userdefaultsKeyPrefix)_\(key)")
    }
    public func boolFromUserDefaults(forKey key: String) -> Bool? {
        return self.config.userDefaults.bool(forKey: "\(Self.userdefaultsKeyPrefix)_\(key)")
    }
    public func integerFromUserDefaults(forKey key: String) -> Int? {
        return self.config.userDefaults.integer(forKey: "\(Self.userdefaultsKeyPrefix)_\(key)")
    }
    public func objectFromUserDefaults(forKey key: String) -> Any? {
        return self.config.userDefaults.object(forKey: "\(Self.userdefaultsKeyPrefix)_\(key)")
    }
    public func setInUserDefaults(_ value: Any?, forKey key: String) {
        self.config.userDefaults.set(value, forKey: "\(Self.userdefaultsKeyPrefix)_\(key)")
    }
    
}

#endif
