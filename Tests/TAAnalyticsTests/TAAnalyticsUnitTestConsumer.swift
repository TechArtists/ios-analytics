//
//  File.swift
//  TAAnalytics
//
//  Created by Adi on 10/20/24.
//

import Foundation
import TAAnalytics

class TAAnalyticsUnitTestConsumer: AnalyticsConsumer {
    
    public var eventsSent = [(event: AnalyticsEventTrimmed, params: [String: AnalyticsBaseParameterValue?])]()
    public var userPropertiesSet = [AnalyticsUserPropertyTrimmed: String]()
    
    public typealias T = TAAnalyticsUnitTestConsumer
    public var wrappedValue: Self {
        self
    }

    
    private let eventTrimLength: Int
    private let userPropertyTrimLength: Int
     
    init(eventTrimLength: Int = 40, userPropertyTrimLength: Int = 24) {
        self.eventTrimLength = eventTrimLength
        self.userPropertyTrimLength = userPropertyTrimLength
    }
    
    func startFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, TAAnalytics: TAAnalytics) async throws {
    }
    
    func track(trimmedEvent: AnalyticsEventTrimmed, params: [String : any AnalyticsBaseParameterValue]?) {
        eventsSent.append((trimmedEvent, params ?? [:]))
    }
    
    func set(trimmedUserProperty: AnalyticsUserPropertyTrimmed, to: String?) {
        guard let to = to else { return }
        userPropertiesSet[trimmedUserProperty] = to
    }
    
    func trim(event: AnalyticsEvent) -> AnalyticsEventTrimmed {
        AnalyticsEventTrimmed(String(event.rawValue.prefix(eventTrimLength)))
    }
    
    public func trim(userProperty: AnalyticsUserProperty) -> AnalyticsUserPropertyTrimmed {
        AnalyticsUserPropertyTrimmed(String(userProperty.rawValue.prefix(userPropertyTrimLength)))
    }
        
    
}
