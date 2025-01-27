//
//  File.swift
//  TAAnalytics
//
//  Created by Adi on 10/20/24.
//

import Foundation
import TAAnalytics

class TAAnalyticsUnitTestConsumer: AnalyticsConsumer {
    
    public var eventsSent = [(event: EventAnalyticsModelTrimmed, params: [String: (any AnalyticsBaseParameterValue)?])]()
    public var userPropertiesSet = [UserPropertyAnalyticsModelTrimmed: String]()
    
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
    
    func track(trimmedEvent: EventAnalyticsModelTrimmed, params: [String : any AnalyticsBaseParameterValue]?) {
        eventsSent.append((trimmedEvent, params ?? [:]))
    }
    
    func set(trimmedUserProperty: UserPropertyAnalyticsModelTrimmed, to: String?) {
        guard let to = to else { return }
        userPropertiesSet[trimmedUserProperty] = to
    }
    
    func trim(event: EventAnalyticsModel) -> EventAnalyticsModelTrimmed {
        EventAnalyticsModelTrimmed(String(event.rawValue.prefix(eventTrimLength)))
    }
    
    public func trim(userProperty: UserPropertyAnalyticsModel) -> UserPropertyAnalyticsModelTrimmed {
        UserPropertyAnalyticsModelTrimmed(String(userProperty.rawValue.prefix(userPropertyTrimLength)))
    }
        
    
}
