//
//  TAAnalyticsAdaptorLogPolicyTests.swift
//  TAAnalytics
//
//  Created by OpenAI on 07.04.2026.
//

import Testing
@testable import TAAnalytics

@Test
func adaptorLogPolicyDisabledDoesNotLogAdaptors() {
    let adaptor = TAAnalyticsUnitTestAdaptor()

    #expect(!TAAnalyticsConfig.AdaptorLogPolicy.disabled.shouldLog(adaptor: adaptor))
}

@Test
func adaptorLogPolicyAllLogsAdaptors() {
    let adaptor = TAAnalyticsUnitTestAdaptor()

    #expect(TAAnalyticsConfig.AdaptorLogPolicy.all.shouldLog(adaptor: adaptor))
}

@Test
func adaptorLogPolicyOnlyLogsSelectedAdaptorTypes() {
    let selectedAdaptor = TAAnalyticsUnitTestAdaptor()
    let otherAdaptor = AlternateTAAnalyticsUnitTestAdaptor()

    let policy = TAAnalyticsConfig.AdaptorLogPolicy.only(TAAnalyticsUnitTestAdaptor.self)

    #expect(policy.shouldLog(adaptor: selectedAdaptor))
    #expect(!policy.shouldLog(adaptor: otherAdaptor))
}

@Test
func adaptorLogPolicyExcludingSuppressesSelectedAdaptorTypes() {
    let excludedAdaptor = TAAnalyticsUnitTestAdaptor()
    let otherAdaptor = AlternateTAAnalyticsUnitTestAdaptor()

    let policy = TAAnalyticsConfig.AdaptorLogPolicy.excluding(TAAnalyticsUnitTestAdaptor.self)

    #expect(!policy.shouldLog(adaptor: excludedAdaptor))
    #expect(policy.shouldLog(adaptor: otherAdaptor))
}

private final class AlternateTAAnalyticsUnitTestAdaptor: TAAnalyticsUnitTestAdaptor {}
